-- generate CeTZ figures in typst documents from a textual description
-- using the google ai studio (gemini) api, queried asynchronously via curl

local M = {}

M.opts = {
	model = 'gemini-3.8-flash',
	-- tried in order when the previous model keeps failing with overload/rate-limit errors
	fallback_models = { 'gemini-3.7-flash', 'gemini-3.5-flash' },
	-- attempts per model before moving on to the next one
	attempts = 2,
	api_key_env = 'GEMINI_API_KEY',
	keymap = '<leader>af',
	cancel_keymap = '<leader>ac',
	-- used when the buffer has no cetz import and none is found in the local package cache
	fallback_cetz_version = '0.4.2',
	-- lines of surrounding document passed to the model as context
	context_lines = 30,
	timeout = 180,
}

local ns = vim.api.nvim_create_namespace('cetz_ai')
local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }

-- active generations, keyed by buf .. ':' .. extmark id
local jobs = {}

local system_prompt = [[
You are an expert in Typst and the CeTZ drawing package (version %s).
Given a description of a figure, write CeTZ code that draws it.

Rules:
- Output ONLY Typst code, no explanations and no markdown code fences.
- The output must be a single `#cetz.canvas({ ... })` expression (optionally wrapped in
  `#figure(...)` or `#align(center, ...)` if that fits the surrounding document).
- Assume `#import "@preview/cetz:%s"` is already present; do not add imports.
- Inside the canvas, start with `import cetz.draw: *`. For plots/charts use the
  `cetz-plot` package only if the user asks for it explicitly.
- Use only APIs that exist in CeTZ %s. Prefer simple, robust constructs
  (line, rect, circle, content, arc, bezier, grid, anchors, named elements).
- Keep coordinates readable and add short `//` comments for the major parts.
- Captions go at the bottom and must never overlap the drawing. Prefer
  `#figure(cetz.canvas({ ... }), caption: [...])`, which places the caption below the
  canvas. Never draw a caption or title as `content` inside the canvas. If some caption-like
  text has to be inside the canvas, anchor it below the lowest drawn element
  (e.g. `content((rel: (0, -0.5), to: "name.south"), anchor: "north", [...])`) with clear spacing.
]]

local function read_api_key()
	local key = vim.env[M.opts.api_key_env]
	if key and key ~= '' then
		return vim.trim(key)
	end
	return nil
end

-- figure out which cetz version the document uses, falling back to the newest cached one
local function cetz_version(buf)
	for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		local v = line:match('@preview/cetz:([%d%.]+)')
		if v then
			return v, true
		end
	end

	local best
	local dirs = {
		vim.fn.expand('~/.cache/typst/packages/preview/cetz'),
		vim.fn.expand('~/.local/share/typst/packages/preview/cetz'),
	}
	for _, dir in ipairs(dirs) do
		for name, type in vim.fs.dir(dir) do
			if type == 'directory' and name:match('^[%d%.]+$') then
				if not best or vim.version.lt(best, name) then
					best = name
				end
			end
		end
	end
	return best or M.opts.fallback_cetz_version, false
end

local function strip_fences(text)
	text = vim.trim(text)
	text = text:gsub('^```[%w_-]*\n', ''):gsub('\n```$', '')
	return vim.trim(text)
end

local function extract_text(body)
	local ok, decoded = pcall(vim.json.decode, body)
	if not ok or type(decoded) ~= 'table' then
		return nil, 'could not decode response: ' .. body:sub(1, 200)
	end
	if decoded.error then
		local retryable = vim.tbl_contains({ 429, 500, 503, 504 }, decoded.error.code)
		return nil, decoded.error.message or vim.inspect(decoded.error), retryable
	end

	local candidate = decoded.candidates and decoded.candidates[1]
	local parts = candidate and candidate.content and candidate.content.parts
	if not parts then
		local reason = candidate and candidate.finishReason
			or (decoded.promptFeedback and decoded.promptFeedback.blockReason)
			or 'unknown'
		return nil, 'no content returned (reason: ' .. reason .. ')'
	end

	local chunks = {}
	for _, part in ipairs(parts) do
		-- skip thought summaries if the model returns any
		if part.text and not part.thought then
			table.insert(chunks, part.text)
		end
	end
	return strip_fences(table.concat(chunks))
end

local function request(api_key, model, payload, callback)
	local tmp = vim.fn.tempname()
	vim.fn.writefile({ vim.json.encode(payload) }, tmp)

	local url = ('https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent'):format(model)

	-- the api key goes through stdin as curl config so it doesn't show up in the process list
	return vim.system({
		'curl', '-sS', '--fail-with-body',
		'--max-time', tostring(M.opts.timeout),
		'-X', 'POST', url,
		'-H', 'Content-Type: application/json',
		'--data-binary', '@' .. tmp,
		'-K', '-',
	}, {
		text = true,
		stdin = ('header = "x-goog-api-key: %s"\n'):format(api_key),
	}, vim.schedule_wrap(function(res)
		os.remove(tmp)
		if res.signal ~= 0 then
			return callback(nil, 'cancelled')
		end
		local text, err, retryable = extract_text(res.stdout or '')
		if not text and res.code ~= 0 and (res.stdout or '') == '' then
			-- network level failure (timeout, dns, ...), worth another try
			err = vim.trim(res.stderr or ('curl exited with ' .. res.code))
			retryable = true
		end
		callback(text, err, retryable)
	end))
end

local function set_status(buf, id, row, text, hl)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
		id = id,
		line_hl_group = 'CetzAiLine',
		virt_text = { { ' ' .. text .. ' ', hl } },
		virt_text_pos = 'eol',
	})
end

local function extmark_row(buf, id)
	if not vim.api.nvim_buf_is_valid(buf) then
		return nil
	end
	local pos = vim.api.nvim_buf_get_extmark_by_id(buf, ns, id, {})
	return pos[1]
end

local function finish(buf, id)
	local key = buf .. ':' .. id
	local job = jobs[key]
	if job and job.timer then
		job.timer:stop()
		job.timer:close()
	end
	jobs[key] = nil
	if vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_buf_del_extmark(buf, ns, id)
	end
end

local function insert_figure(buf, row, text)
	local current = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ''
	local indent = current:match('^%s*')
	local lines = vim.split(text, '\n', { plain = true })
	for i, l in ipairs(lines) do
		lines[i] = l ~= '' and indent .. l or l
	end

	-- replace the line if it is blank, otherwise put the figure below it
	if vim.trim(current) == '' then
		vim.api.nvim_buf_set_lines(buf, row, row + 1, false, lines)
	else
		vim.api.nvim_buf_set_lines(buf, row + 1, row + 1, false, lines)
	end
end

local function ensure_import(buf, version)
	local import = ('#import "@preview/cetz:%s"'):format(version)
	vim.api.nvim_buf_set_lines(buf, 0, 0, false, { import })
end

function M.generate(buf, row, description)
	local api_key = read_api_key()
	if not api_key then
		vim.notify(('cetz_ai: $%s is not set'):format(M.opts.api_key_env), vim.log.levels.ERROR)
		return
	end

	local version, has_import = cetz_version(buf)

	local first = math.max(0, row - M.opts.context_lines)
	local last = row + M.opts.context_lines
	local context = table.concat(vim.api.nvim_buf_get_lines(buf, first, last, false), '\n')

	local payload = {
		system_instruction = { parts = { { text = system_prompt:format(version, version, version) } } },
		contents = { {
			role = 'user',
			parts = { {
				text = ('Surrounding document (the figure goes at the marked line):\n%s\n\nFigure description:\n%s')
					:format(context, description),
			} },
		} },
		generationConfig = { temperature = 0.3 },
	}

	local id = vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {})
	local key = buf .. ':' .. id
	local job = { timer = vim.uv.new_timer(), frame = 1, started = vim.uv.now(), note = '' }
	jobs[key] = job

	local function render()
		local r = extmark_row(buf, id)
		if not r then
			return
		end
		local secs = math.floor((vim.uv.now() - job.started) / 1000)
		set_status(buf, id, r, ('%s generating CeTZ figure… %ds%s'):format(spinner[job.frame], secs, job.note), 'CetzAiStatus')
	end
	render()
	job.timer:start(100, 100, vim.schedule_wrap(function()
		if not jobs[key] then
			return
		end
		job.frame = job.frame % #spinner + 1
		render()
	end))

	local models = { M.opts.model, unpack(M.opts.fallback_models) }
	local model_idx, attempt = 1, 1

	local function on_response(text, err, retryable)
		if not jobs[key] then
			return
		end
		if not text and retryable and err ~= 'cancelled' then
			if attempt < M.opts.attempts then
				attempt = attempt + 1
			elseif model_idx < #models then
				model_idx, attempt = model_idx + 1, 1
			else
				retryable = false
			end
		end

		if not text and retryable and err ~= 'cancelled' then
			local delay = attempt == 1 and 0 or 2000 * (attempt - 1)
			job.note = (' (%s, attempt %d: %s)'):format(models[model_idx], attempt, err:sub(1, 40))
			job.proc = nil
			vim.defer_fn(function()
				if jobs[key] and not job.cancelled then
					job.proc = request(api_key, models[model_idx], payload, on_response)
				end
			end, delay)
			return
		end

		local r = extmark_row(buf, id)
		finish(buf, id)
		if not r then
			return
		end
		if not text then
			if err ~= 'cancelled' then
				vim.notify('cetz_ai: ' .. (err or 'unknown error'), vim.log.levels.ERROR)
			end
			return
		end

		insert_figure(buf, r, text)
		if not has_import then
			ensure_import(buf, version)
		end
		vim.notify(('cetz_ai: figure inserted (%s)'):format(models[model_idx]), vim.log.levels.INFO)
	end

	job.proc = request(api_key, models[model_idx], payload, on_response)
end

-- cancel all generations whose status line is the cursor line
function M.cancel()
	local buf = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, { row, 0 }, { row, -1 }, {})) do
		local job = jobs[buf .. ':' .. mark[1]]
		if job then
			job.cancelled = true
			if job.proc then
				job.proc:kill('sigterm')
			else
				-- waiting between retries, no process to kill
				finish(buf, mark[1])
			end
		end
	end
end

function M.prompt()
	local buf = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1

	local input = vim.api.nvim_create_buf(false, true)
	vim.bo[input].bufhidden = 'wipe'
	vim.bo[input].filetype = 'markdown'

	local width = math.min(80, math.floor(vim.o.columns * 0.7))
	local height = 6
	local win = vim.api.nvim_open_win(input, true, {
		relative = 'editor',
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2) - 1,
		col = math.floor((vim.o.columns - width) / 2),
		style = 'minimal',
		border = 'rounded',
		title = ' CeTZ figure description ',
		title_pos = 'center',
		footer = ' <C-s>/<CR> submit · q/<Esc> cancel ',
		footer_pos = 'center',
	})
	vim.wo[win].wrap = true
	vim.cmd.startinsert()

	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	local function submit()
		local text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(input, 0, -1, false), '\n'))
		vim.cmd.stopinsert()
		close()
		if text ~= '' and vim.api.nvim_buf_is_valid(buf) then
			M.generate(buf, row, text)
		end
	end

	local map_opts = { buffer = input, silent = true, nowait = true }
	vim.keymap.set({ 'n', 'i' }, '<C-s>', submit, map_opts)
	vim.keymap.set('n', '<CR>', submit, map_opts)
	vim.keymap.set('n', 'q', close, map_opts)
	vim.keymap.set('n', '<Esc>', close, map_opts)
end

function M.setup(opts)
	M.opts = vim.tbl_deep_extend('force', M.opts, opts or {})

	local group = vim.api.nvim_create_augroup('CetzAi', {})

	local function set_highlights()
		vim.api.nvim_set_hl(0, 'CetzAiLine', { link = 'CursorLine', default = true })
		vim.api.nvim_set_hl(0, 'CetzAiStatus', { link = 'DiagnosticVirtualTextInfo', default = true })
	end
	set_highlights()
	vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = set_highlights })

	vim.api.nvim_create_autocmd('FileType', {
		desc = 'cetz ai figure keymaps',
		group = group,
		pattern = 'typst',
		callback = function(ev)
			vim.keymap.set('n', M.opts.keymap, M.prompt,
				{ buffer = ev.buf, desc = 'generate CeTZ figure with ai', silent = true })
			vim.keymap.set('n', M.opts.cancel_keymap, M.cancel,
				{ buffer = ev.buf, desc = 'cancel CeTZ figure generation on this line', silent = true })
		end,
	})
end

return M
