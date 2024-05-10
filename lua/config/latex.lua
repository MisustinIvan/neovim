local function compile_latex()
	vim.cmd("silent !pdflatex %")
end

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.tex",
	callback = compile_latex,
})
