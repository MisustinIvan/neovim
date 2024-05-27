return {
	"MisustinIvan/colorsync",
	config = function()
		require("colorsync").setup({
			lualine_theme_dir = "plugins.lualine.themes",
			pairs = {
				["gruber-darker"] = "gruber_darker",
				["catppuccin-macchiato"] = "onedark",
				["onedark_vivid"] = "onedark",
				["onedark_dark"] = "onedark",
			},
		})
	end,
	cmd = { "ColorSync" },
}
