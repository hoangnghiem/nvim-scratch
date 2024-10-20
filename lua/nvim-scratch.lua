local Path = require("plenary.path")
local Popup = require("nui.popup")
-- local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

-- Keep track of the currently opened popup
local popup_instance = nil

local function create_file_if_not_exists(filepath)
	local path = Path:new(filepath)

	-- Check if file exists
	if not path:exists() then
		-- Create the file
		path:touch({ parents = true }) -- creates parent directories if they don't exist
	end
end

-- Function to open the file in a popup
local function open_file_in_popup(filepath)
	-- If a popup is already open, close it
	if popup_instance then
		-- Save the file before closing
		vim.cmd("write")
		popup_instance:unmount()
		popup_instance = nil
		return
	end

	-- Create popup with file content
	popup_instance = Popup({
		enter = true,
		focusable = true,
		zindex = 50,
		relative = "editor",
		border = {
			style = "rounded",
			text = {
				top = "scratch.md",
				top_align = "center",
			},
		},
		position = "50%",
		size = {
			width = "70%",
			height = "70%",
		},
		buf_options = {
			modifiable = true,
			readonly = false,
		},
		win_options = {
			winblend = 10,
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
	})

	--  Mount the popup and load the file content
	popup_instance:mount()

	-- Focus the popup window after it is mounted
	vim.api.nvim_set_current_win(popup_instance.winid)

	-- Open the scratch file in the buffer
	vim.cmd("edit " .. filepath)

	-- Automatically save the file when leaving the popup
	popup_instance:on(event.BufLeave, function()
		vim.cmd("write")
		popup_instance:unmount()
		popup_instance = nil
	end)

	-- Close on `q` or `<Esc>` and save the file
	popup_instance:map("n", "q", function()
		vim.cmd("write")
		popup_instance:unmount()
		popup_instance = nil
	end, { noremap = true })

	popup_instance:map("n", "<Esc>", function()
		vim.cmd("write")
		popup_instance:unmount()
		popup_instance = nil
	end, { noremap = true })
end

local function toggle_scratch()
	local scratch_file = vim.fn.stdpath("config") .. "/data/scratch.md"
	create_file_if_not_exists(scratch_file)
	open_file_in_popup(scratch_file)
end

return {
	toggle_scratch = toggle_scratch,
}
