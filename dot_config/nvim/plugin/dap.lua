local dap = require("dap")

vim.fn.sign_define('DapBreakpoint',{ text ='B', texthl ='ErrorMsg', linehl ='', numhl =''})
vim.fn.sign_define('DapStopped',{ text ='', texthl ='', linehl ='CurSearch', numhl =''})
local function open_and_focus_repl()
    -- Open the REPL
    dap.repl.open()

    -- Get the last window (the REPL should be the last)
    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "dap-repl" then
            -- Focus the REPL window
            vim.api.nvim_set_current_win(win)
            break
        end
    end
end

vim.api.nvim_create_user_command("DB", function() dap.continue(); open_and_focus_repl() end, {})
vim.keymap.set('n', '<leader>da', dap.toggle_breakpoint, {})
vim.keymap.set('n', '<leader>dr', open_and_focus_repl, {})
vim.keymap.set('n', '<F5>', dap.continue)
vim.keymap.set('n', '<leader>dd', dap.continue)
vim.keymap.set('n', '<leader>df', dap.step_over)
vim.keymap.set('n', '<leader>di', dap.step_into)
vim.keymap.set('n', '<leader>do', dap.step_out)
vim.keymap.set('n', '<leader>dw', dap.up)
vim.keymap.set('n', '<leader>ds', dap.down)

dap.adapters.python = {
    type = 'executable',
    command = "python",
    args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch current file",
    program = "${file}",       -- run the current file
  },
}


-- Create a namespace for our plugin
local except_ns = vim.api.nvim_create_namespace("dap-exceptionInfo")
local except_bufnrs = {}

local function show_box(lines, linenr, bufnr)
  -- Clear any previous boxes we drew
  vim.api.nvim_buf_clear_namespace(bufnr, except_ns, 0, -1)

  -- Add virtual lines below
  vim.api.nvim_buf_set_extmark(bufnr, except_ns, linenr - 1, 0, {
    virt_lines = vim.tbl_map(function(line)
      return { { line, "ErrorMsg" } }  -- you can change "Comment" to any hl group
    end, lines),
    virt_lines_above = false, -- means put it *below* the row
  })
end

dap.listeners.after['exceptionInfo']['print-exception'] = function(session, err, response, request, seq)
  if err then
    print('ExceptionInfo request failed:', vim.inspect(err))
  else
	  local bufnr = vim.fn.bufnr(session.config.program, true)
  	  table.insert(except_bufnrs, bufnr)
	  local linenr = session.current_frame.line
	  show_box({response.exceptionId, response.description}, linenr, bufnr)
  end
end

dap.listeners.after["event_terminated"]["print-exception"] = function(session, payload)
	for key, bufnr in pairs(except_bufnrs) do
		vim.api.nvim_buf_clear_namespace(bufnr, except_ns, 0, -1)
	end
	except_bufnrs = {}
end
