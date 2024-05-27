return {
	"MisustinIvan/music_info",
	config = function()
		require("music_info").setup({ "playerctl" })
	end,
	cmd = { "MusicInfo" },
}
