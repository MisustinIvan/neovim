-- Player service : org.mpris.MediaPlayer2
-- Player path : /org/mpris/MediaPlayer2
-- Player interface : org.mpris.MediaPlayer2.Player
-- Player properties interface : org.freedesktop.DBus.Properties
-- Player metadata : xesam:artist, xesam:title
-- Player metadata artist : xesam:artist
-- Player metadata title : xesam:title

---@class music_info_opts
---@field backend "playerctl"

---@class music_info
---@field setup fun(opts: music_info_opts)
---@field music_info fun(): string
---@field version string
---@field opts music_info_opts

---@type music_info
local M = {}

--- Setup function for the plugin
--- @param opts music_info_opts
M.setup = function(opts)
	M.opts = opts

	vim.api.nvim_create_user_command("MusicInfo", function()
		print(M.music_info())
	end, {
		bang = false,
	})
end

--- Retrieve music information
--- @return string
M.music_info = function()
	---@type file*?, string?
	local artist_handle, artist_err = io.popen("playerctl metadata xesam:artist 2>&1", "r")
	if not artist_handle then
		return "Error: " .. artist_err
	end
	local artist = artist_handle:read("*a"):gsub("\n", "")
	artist_handle:close()

	if artist == "No players found" then
		return "No music playing"
	end

	---@type file*?, string?
	local title_handle, title_err = io.popen("playerctl metadata xesam:title 2>&1", "r")
	if not title_handle then
		return "Error: " .. title_err
	end
	local title = title_handle:read("*a"):gsub("\n", "")
	title_handle:close()

	if title == "No players found" then
		return "No music playing"
	end

	return artist .. " - " .. title
end

M.version = "1.0.0"

return M
