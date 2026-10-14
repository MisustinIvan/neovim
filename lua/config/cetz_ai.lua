-- generate CeTZ figures in typst documents from a textual description
-- using an llm api (e-infra cz or google ai studio), queried asynchronously via curl

local M = {}

M.opts = {
	provider = 'einfra',
	providers = {
		-- openai compatible api of e-infra cz / cerit-sc, https://docs.cerit-sc.cz/en/docs/ai-as-a-service/ai-api
		einfra = {
			-- picked by a benchmark of all e-infra chat models on 8 figure types (oct 2026),
			-- compiled with typst and judged visually; these are e-infra aliases and may change
			model = 'deepseek-thinking',
			-- tried in order when the previous model keeps failing with overload/rate-limit errors
			fallback_models = { 'deepseek-v4.1-flash-thinking', 'thinker' },
			api_key_env = 'E_INFRA_API_TOKEN',
			-- thinking models can reason for minutes on harder figures, 'low' roughly halves that
			reasoning_effort = 'low',
		},
		gemini = {
			model = 'gemini-3.8-flash',
			fallback_models = { 'gemini-3.7-flash', 'gemini-3.6-flash', 'gemini-3.5-flash' },
			api_key_env = 'GEMINI_API_KEY',
		},
	},
	-- attempts per model before moving on to the next one
	attempts = 2,
	keymap = '<leader>af',
	cancel_keymap = '<leader>ac',
	-- used when the buffer has no cetz import and none is found in the local package cache
	fallback_cetz_version = '0.4.2',
	-- lines of surrounding document passed to the model as context
	context_lines = 30,
	-- the response is streamed: give up on a model when nothing arrives for idle_timeout seconds,
	-- or when a single request runs longer than timeout seconds overall
	idle_timeout = 60,
	timeout = 600,
	-- send a desktop notification via notify-send when a generation finishes
	desktop_notify = true,
}

local ns = vim.api.nvim_create_namespace('cetz_ai')
local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }

-- active generations, keyed by buf .. ':' .. extmark id
local jobs = {}

local system_prompt = [[
You are an expert in Typst and the CeTZ drawing package (version %s). Given a description of a
figure, you write CeTZ code that compiles on the first try and looks clean.

# Output contract
- Output ONLY Typst code: no explanations, no markdown fences, no comments addressed to the user,
  no "wait, let me fix that" self-corrections. Think before writing; emit only the final version.
- Exactly one figure. If the description mentions a caption, output
  `#figure(cetz.canvas({ ... }), caption: [...])`, otherwise a bare `#cetz.canvas({ ... })`.
  Never output the drawing twice.
- Assume `#import "@preview/cetz:%s"` is already present; do not add imports.
- Start the canvas body with `import cetz.draw: *`. Do not use `cetz-plot` unless asked.
- Use only APIs that exist in CeTZ %s and follow the reference below exactly.

# Layout
- Keep the default `cetz.canvas` length (1cm per unit). Make the drawing roughly 6-12 units wide.
  Never pass `length:` to the canvas.
- Use a restrained palette: soft fills to distinguish groups or sets (e.g. `fill: blue.lighten(80%%)`)
  with a matching darker stroke (`stroke: blue.darken(30%%)`); default-width strokes; black for
  plain lines, arrows and text. Faint gray lines only for dense secondary connections.
- Leave at least 0.8 units between separate boxes/nodes so arrows and labels have room.
- Labels must never overlap lines, shapes or other labels: place them with an `anchor` and a
  `padding`, pointing away from the element they describe.
- The caption belongs to `#figure`, never drawn as `content` inside the canvas.

# CeTZ reference (correct usage)
- Text and boxes: `content(position, body, anchor: "north", padding: 0.1)`. The position is ONE
  coordinate argument. For a box that fits its text use
  `content((0, 0), [Read input], frame: "rect", padding: 0.2, name: "read")`; never size boxes
  for text by hand. Use `frame: "circle"` for nodes with text inside.
- Coordinates: `(x, y)`; relative `(rel: (dx, dy), to: point)`; interpolation `(a, 50%%, b)`;
  offset from an interpolated point `(rel: (0, 0.2), to: (a, 50%%, b))`; orthogonal corner
  `(a, "|-", b)` (x of a, y of b) or `(a, "-|", b)`. Typst arrays do not support arithmetic, so
  never write `(A + B) / 2` or append numbers to a coordinate. Element names inside coordinates
  are strings too: `("q0", 50%%, "q2")`, never `(q0, 50%%, q2)`.
- Named elements: `circle((0, 0), radius: 0.4, name: "q0")`, then refer to "q0", "q0.east",
  "q0.north-west". Anchors are ALWAYS strings with hyphens: "north", "south-east", "center", ...
  Never `q0.east` (unquoted) or "south east".
- Every `line(...)` path element gets a "mid"/"start"/"end" anchor: `line(a, b, name: "e")`
  then `content("e.mid", [label], anchor: "south", padding: 0.1)`.
- A closed `line(..., close: true)` (e.g. a diamond) has no compass anchors, only "centroid".
  Store its corners in `let` variables and connect arrows to those:
  `let D = (0, -3)`, `let top = (rel: (0, 0.7), to: D)`, ... `line(top, right, bottom, left, close: true)`.
- Arrows: `line(a, b, mark: (end: ">"))`. Orthogonal routing: `line(a, (a, "|-", b), b, mark: (end: ">"))`.
- Curves: `bezier(start, end, ctrl)` or `bezier(start, end, ctrl1, ctrl2)`; at least one
  control point is required. Self loop on a node:
  `bezier("q.north-west", "q.north-east", (rel: (-0.5, 1.2), to: "q.north"), (rel: (0.5, 1.2), to: "q.north"), mark: (end: ">"))`.
- Double circle (e.g. accepting state): two `circle`s with radii r and 0.8 * r at the same center.
- Other shapes: `rect(a, b)`, `circle(center, radius: r)`, `arc(pos, start: 0deg, stop: 90deg, radius: r)`,
  `grid(from, to, step: 0.5)`, `group({ set-origin((x, y)); ... })`.
- Function plots: sample points in a loop and draw one line through them:
  `let pts = range(61).map(i => { let x = 2 * calc.pi * i / 60; (x, calc.sin(x)) })`, `line(..pts)`.
- Math: a `let` variable shadows the symbol of the same name inside every `$...$`, so
  `let delta = 1.2` makes `$a - delta$` render as "a - 1.2" and `let pi = calc.pi` makes `$pi/2$`
  render as 1.5707... Never name variables after Greek letters or other math symbols (`pi`, `delta`,
  `epsilon`, `alpha`, `theta`, `sigma`, `mu`, `lambda`, ...); use names like `d-val`, `eps-val`.
  Use `calc.pi` in computations and `$pi/2$`, `$a - delta$` in labels.
- Text labels are content blocks `[Start]`; use math mode only for symbols and formulas
  (`$a$`, `$q_0$`, `$x^2$`). Never `$Start$`.
- Typst has no global `zip`/`len`/`map`; use methods: `a.zip(b)`, `a.len()`, `a.map(f)`.
  Lengths outside the canvas need units (`inset: 2pt`), but prefer CeTZ `frame:` over Typst `box`.
- `#figure` accepts the body and `caption`, `kind`, `supplement`, `placement`, `gap`,
  `numbering`, `outlined`. It has no `width`.
]]

local function provider()
	return M.opts.providers[M.opts.provider]
end

-- returns the system and user messages, the figure goes between the before and after lines
function M.build_prompt(version, before, after, description)
	local context = vim.list_extend(vim.list_extend(vim.list_slice(before), { '<<< FIGURE GOES HERE >>>' }), after)
	local user = ('Surrounding document (the figure goes at the <<< FIGURE GOES HERE >>> marker):\n%s\n\nFigure description:\n%s')
		:format(table.concat(context, '\n'), description)
	return system_prompt:format(version, version, version), user
end

local function read_api_key()
	local key = vim.env[provider().api_key_env]
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

local function strip_thinking(text)
	return (text:gsub('^%s*<think>.-</think>', ''))
end

-- each backend turns a request into curl arguments and each streamed (sse) event into
-- a { content = ..., reasoning = ..., finish = ... } delta
local backends = {
	gemini = {
		url = function(model)
			return ('https://generativelanguage.googleapis.com/v1beta/models/%s:streamGenerateContent?alt=sse')
				:format(model)
		end,
		auth_header = function(key) return 'x-goog-api-key: ' .. key end,
		payload = function(_, system, user)
			return {
				system_instruction = { parts = { { text = system } } },
				contents = { { role = 'user', parts = { { text = user } } } },
				generationConfig = { temperature = 0.3 },
			}
		end,
		chunk = function(decoded)
			local candidate = decoded.candidates and decoded.candidates[1]
			local delta = {
				finish = (candidate and candidate.finishReason)
					or (decoded.promptFeedback and decoded.promptFeedback.blockReason),
			}
			local parts = candidate and candidate.content and candidate.content.parts or {}
			for _, part in ipairs(parts) do
				if part.text then
					-- thought summaries count as reasoning, not as the answer
					local field = part.thought and 'reasoning' or 'content'
					delta[field] = (delta[field] or '') .. part.text
				end
			end
			return delta
		end,
	},
	einfra = {
		url = function() return 'https://llm.ai.e-infra.cz/v1/chat/completions' end,
		auth_header = function(key) return 'Authorization: Bearer ' .. key end,
		payload = function(model, system, user)
			return {
				model = model,
				messages = {
					{ role = 'system', content = system },
					{ role = 'user', content = user },
				},
				temperature = 0.3,
				stream = true,
				reasoning_effort = provider().reasoning_effort,
			}
		end,
		chunk = function(decoded)
			local choice = decoded.choices and decoded.choices[1] or {}
			local d = choice.delta or {}
			local reasoning = d.reasoning_content or d.reasoning
			return {
				content = type(d.content) == 'string' and d.content or nil,
				reasoning = type(reasoning) == 'string' and reasoning or nil,
				finish = choice.finish_reason ~= vim.NIL and choice.finish_reason or nil,
			}
		end,
	},
}

local function error_message(decoded)
	local e = decoded.error
	if type(e) == 'table' then
		return e.message or vim.inspect(e)
	end
	return e or decoded.detail and vim.inspect(decoded.detail) or nil
end

local retryable_status = { [429] = true, [500] = true, [502] = true, [503] = true, [504] = true }

-- callback(text, err, retry) where retry is 'same' for transient errors worth retrying on the
-- same model, 'next' for a stalled/too slow model, nil otherwise
-- progress({ reasoning = n, content = n }) is called as tokens stream in
local function request(api_key, model, system, user, progress, callback)
	local backend = backends[M.opts.provider]
	local tmp = vim.fn.tempname()
	vim.fn.writefile({ vim.json.encode(backend.payload(model, system, user)) }, tmp)

	local pending = ''
	local content, raw = {}, {}
	local counts = { reasoning = 0, content = 0 }
	local finish, stream_err

	local function handle_line(line)
		local data = line:match('^data:%s*(.*)$')
		if not data then
			-- not an sse event: a plain json error body, or the trailing http status
			table.insert(raw, line)
			return
		end
		if data == '[DONE]' or data == '' then
			return
		end
		local ok, decoded = pcall(vim.json.decode, data)
		if not ok or type(decoded) ~= 'table' then
			return
		end
		if decoded.error then
			stream_err = error_message(decoded)
			return
		end
		local delta = backend.chunk(decoded)
		-- streams often open with empty deltas, only count real tokens
		if delta.reasoning and delta.reasoning ~= '' then
			counts.reasoning = counts.reasoning + 1
		end
		if delta.content and delta.content ~= '' then
			counts.content = counts.content + 1
			table.insert(content, delta.content)
		end
		finish = delta.finish or finish
	end

	-- the api key goes through stdin as curl config so it doesn't show up in the process list,
	-- the http status is appended on its own line after the body
	return vim.system({
		'curl', '-sS', '-N',
		'--max-time', tostring(M.opts.timeout),
		'--speed-limit', '1', '--speed-time', tostring(M.opts.idle_timeout),
		'-X', 'POST', backend.url(model),
		'-H', 'Content-Type: application/json',
		'--data-binary', '@' .. tmp,
		'-w', '\n%{http_code}',
		'-K', '-',
	}, {
		text = true,
		stdin = ('header = "%s"\n'):format(backend.auth_header(api_key)),
		stdout = function(_, data)
			if not data then
				return
			end
			pending = pending .. data
			for line in pending:gmatch('(.-)\r?\n') do
				handle_line(line)
			end
			pending = pending:match('[^\n]*$')
			vim.schedule(function() progress(counts) end)
		end,
	}, vim.schedule_wrap(function(res)
		os.remove(tmp)
		if res.signal ~= 0 then
			return callback(nil, 'cancelled')
		end
		if res.code == 28 then
			return callback(nil, ('%s stalled or took too long (%d thinking, %d answer tokens)')
				:format(model, counts.reasoning, counts.content), 'next')
		end
		if res.code ~= 0 then
			-- network level failure (dns, connection reset, ...), worth another try
			return callback(nil, vim.trim(res.stderr or ('curl exited with ' .. res.code)), 'same')
		end

		-- whatever is left after the last newline is the http status from -w
		local status = tonumber(vim.trim(pending)) or 0
		local retry = retryable_status[status] and 'same' or nil
		if status >= 400 or stream_err then
			local body = table.concat(raw, '\n')
			local ok, decoded = pcall(vim.json.decode, body)
			local msg = stream_err or (ok and type(decoded) == 'table' and error_message(decoded))
				or vim.trim(body):sub(1, 200)
			return callback(nil, ('HTTP %d: %s'):format(status, msg), retry)
		end

		local text = strip_fences(strip_thinking(table.concat(content)))
		if text == '' then
			return callback(nil, 'no content returned (reason: ' .. tostring(finish) .. ')')
		end
		callback(text)
	end))
end

local function desktop_notify(summary, body, urgency)
	if not M.opts.desktop_notify or vim.fn.executable('notify-send') == 0 then
		return
	end
	vim.system({ 'notify-send', '-a', 'nvim', '-u', urgency or 'normal', summary, body })
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
		vim.notify(('cetz_ai: $%s is not set'):format(provider().api_key_env), vim.log.levels.ERROR)
		return
	end

	local version, has_import = cetz_version(buf)

	-- mirrors insert_figure: a blank target line is replaced, otherwise the figure goes below it
	local split = vim.trim(vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or '') == '' and row or row + 1
	local before = vim.api.nvim_buf_get_lines(buf, math.max(0, split - M.opts.context_lines), split, false)
	local after = vim.api.nvim_buf_get_lines(buf, row + 1, split + M.opts.context_lines, false)
	local system, user = M.build_prompt(version, before, after, description)

	local id = vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {})
	local key = buf .. ':' .. id
	local job = { timer = vim.uv.new_timer(), frame = 1, started = vim.uv.now(), note = '', phase = 'waiting' }
	jobs[key] = job

	local function render()
		local r = extmark_row(buf, id)
		if not r then
			return
		end
		local secs = math.floor((vim.uv.now() - job.started) / 1000)
		set_status(buf, id, r, ('%s CeTZ figure: %s · %ds · %s%s'):format(
			spinner[job.frame], job.phase, secs, job.model, job.note), 'CetzAiStatus')
	end
	render()
	job.timer:start(100, 100, vim.schedule_wrap(function()
		if not jobs[key] then
			return
		end
		job.frame = job.frame % #spinner + 1
		render()
	end))

	local models = { provider().model, unpack(provider().fallback_models) }
	local model_idx, attempt = 1, 1
	job.model = models[model_idx]

	local function on_progress(counts)
		if counts.content > 0 then
			job.phase = ('writing %d tokens'):format(counts.content)
		elseif counts.reasoning > 0 then
			job.phase = ('thinking %d tokens'):format(counts.reasoning)
		end
	end

	local on_response

	local function start()
		job.model, job.phase = models[model_idx], 'waiting'
		job.proc = request(api_key, models[model_idx], system, user, on_progress, on_response)
	end

	on_response = function(text, err, retry)
		if not jobs[key] then
			return
		end
		-- transient errors are retried on the same model, a stalled model is skipped right away
		if not text and retry == 'same' and attempt < M.opts.attempts then
			attempt = attempt + 1
		elseif not text and retry and model_idx < #models then
			model_idx, attempt = model_idx + 1, 1
		else
			retry = nil
		end

		if not text and retry then
			local delay = attempt == 1 and 0 or 2000 * (attempt - 1)
			job.note = (' (retry %d: %s)'):format(attempt, err:sub(1, 50))
			job.proc = nil
			vim.defer_fn(function()
				if jobs[key] and not job.cancelled then
					start()
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
				desktop_notify('CeTZ figure generation failed', err or 'unknown error', 'critical')
			end
			return
		end

		insert_figure(buf, r, text)
		if not has_import then
			ensure_import(buf, version)
		end
		vim.notify(('cetz_ai: figure inserted (%s)'):format(models[model_idx]), vim.log.levels.INFO)
		desktop_notify('CeTZ figure generated', ('%s:%d (%s)'):format(
			vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t'), r + 1, models[model_idx]))
	end

	start()
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
	if not backends[M.opts.provider] then
		vim.notify('cetz_ai: unknown provider ' .. tostring(M.opts.provider), vim.log.levels.ERROR)
		return
	end

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
