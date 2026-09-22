---@class PackChangedEvent
---@field data { spec: { name: string, src?: string }, kind: "install" | "update" | "delete", path: string }

---@alias PackChangedCallback fun(ev: PackChangedEvent): nil

---@class PackConfig
---@field callbacks PackChangedCallback[]
---@field run_callbacks fun(ev: PackChangedEvent): nil
---@field add_callback fun(callback: PackChangedCallback): nil

---@type PackConfig
local M = {}

M.callbacks = {}

---@param ev PackChangedEvent
M.run_callbacks = function(ev)
	for _, callback in ipairs(M.callbacks) do
		local ok, err = pcall(callback, ev)
		if not ok then
			vim.notify("PackChanged hook error: " .. tostring(err), vim.log.levels.ERROR)
		end
	end
end

---@param callback PackChangedCallback
M.add_callback = function(callback)
	table.insert(M.callbacks, callback)
end

return M
