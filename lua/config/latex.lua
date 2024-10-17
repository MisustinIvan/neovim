local function compile_latex()
    path = vim.api.nvim_buf_get_name(0)
	vim.cmd("silent !pdflatex " .. path)
end

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.tex",
	callback = compile_latex,
})
