local augroup = vim.api.nvim_create_augroup('UserConfig', {})

vim.api.nvim_create_autocmd('VimResized', {
	desc = 'auto resize splits when window is resized',
	group = augroup,
	callback = function()
		vim.cmd('wincmd =')
	end,
})

vim.api.nvim_create_autocmd('BufWritePost', {
	desc = 'compile latex on file save',
	group = augroup,
	pattern = '*.tex',
	callback = function()
		local path = vim.api.nvim_buf_get_name(0)
		vim.cmd('silent !pdflatex ' .. path)
	end,
})

vim.api.nvim_create_autocmd('TermClose', {
	desc = 'auto close terminal when process exits',
	group = augroup,
	callback = function()
		if vim.v.event.status == 0 then
			vim.api.nvim_buf_delete(0, {})
		end
	end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'highlight text after yank',
	group = augroup,
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- one `typst watch` per source file, keyed by absolute path
local typst_watch_jobs = {}

local function stop_typst_watch(src)
	local job = typst_watch_jobs[src]
	if job then
		vim.fn.jobstop(job)
		typst_watch_jobs[src] = nil
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "typst",
	group = augroup,
	callback = function(ev)
		local src = vim.api.nvim_buf_get_name(ev.buf)
		if src == "" then return end
		local pdf = vim.fn.fnamemodify(src, ":r") .. ".pdf"

		-- Compile in background (only if not already watching this file)
		if not typst_watch_jobs[src] then
			local job = vim.fn.jobstart({ "typst", "watch", src, pdf }, {
				on_exit = function(id)
					if typst_watch_jobs[src] == id then
						typst_watch_jobs[src] = nil
					end
				end,
			})
			if job > 0 then
				typst_watch_jobs[src] = job
			end
		end

		-- Stop watching once the buffer goes away
		vim.api.nvim_clear_autocmds({ group = augroup, event = "BufUnload", buffer = ev.buf })
		vim.api.nvim_create_autocmd("BufUnload", {
			group = augroup,
			buffer = ev.buf,
			once = true,
			callback = function()
				stop_typst_watch(src)
			end,
		})

		-- Open termpdf in a kitty split window
		-- --location=vsplit is only honoured by kitty's "splits" layout; in any
		-- other layout (default is "fat") the new window lands at the bottom.
		vim.keymap.set("n", "<leader>tp", function()
			vim.system({ "kitty", "@", "goto-layout", "splits" }, {}, function()
				vim.system({
					"kitty", "@", "launch",
					"--location=vsplit",
					"--keep-focus",
					"--cwd=current",
					"termpdf.py", pdf
				})
			end)
		end, { buffer = true, desc = "Typst: Open internal Kitty preview" })
	end,
})
