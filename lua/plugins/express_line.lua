return {
	"tjdevries/express_line.nvim",
	config = function()
		local generator = function()
			local segments = {}
			local builtin = require("el.builtin")

			table.insert(segments, builtin.file_relative)
			table.insert(segments, " ")
			table.insert(segments, builtin.modified)
			table.insert(segments, builtin.help)
			table.insert(segments, builtin.readonly)
			table.insert(segments, builtin.preview)
			table.insert(segments, builtin.filetype)
			--table.insert(segments, builtin.keymap)
			table.insert(segments, "[")
			table.insert(segments, builtin.line)
			table.insert(segments, ":")
			table.insert(segments, builtin.column)
			table.insert(segments, "]")

			return segments
		end

		require("el").setup({ generator = generator })
	end,
}
