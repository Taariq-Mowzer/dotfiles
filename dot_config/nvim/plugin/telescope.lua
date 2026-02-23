local builtin = require('telescope.builtin')
local action_state = require('telescope.actions.state')
local actions = require('telescope.actions')
local utils = require('telescope.utils')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local make_entry = require('telescope.make_entry')
local conf = require("telescope.config").values

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})

buffer_searcher = function()
    builtin.buffers {
        sort_mru = true,
        ignore_current_buffer = true,
        show_all_buffers = false,
        attach_mappings = function(prompt_bufnr, map)
            local refresh_buffer_searcher = function()
                actions.close(prompt_bufnr)
                vim.schedule(buffer_searcher)
            end

            local delete_buf = function()
                local selection = action_state.get_selected_entry()
                vim.api.nvim_buf_delete(selection.bufnr, { force = true })
                refresh_buffer_searcher()
            end

            local delete_multiple_buf = function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selection = picker:get_multi_selection()
                for _, entry in ipairs(selection) do
                    vim.api.nvim_buf_delete(entry.bufnr, { force = true })
                end
                refresh_buffer_searcher()
            end

            map('n', 'dd', delete_buf)
            map('n', '<C-d>', delete_multiple_buf)
            map('i', '<C-d>', delete_multiple_buf)

            return true
        end
    }
end

local function reverse(tab)
    for i = 1, math.floor(#tab/2), 1 do
        tab[i], tab[#tab-i+1] = tab[#tab-i+1], tab[i]
    end
    return tab
end


vim.api.nvim_create_user_command('LS',  function()
	local output = vim.api.nvim_exec("ls t", true)
	local lines = vim.split(output, "\n")
	lines = reverse(lines)
	local output_reversed = table.concat(lines, "\n")
	vim.notify(output_reversed)
end, {})

vim.keymap.set('n', '<leader>ls', buffer_searcher, {})
vim.keymap.set('n', '<leader>bl', ':LS<CR>:b ', { noremap = true })

local function local_marks()
  local bufnr = vim.api.nvim_get_current_buf()
  local local_marks = {
    items = vim.fn.getmarklist(bufnr),
    name_func = function(_, line)
      return vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    end,
  }
  local marks_table = {}
  local marks_others = {}
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  for _, v in ipairs(local_marks.items) do
    -- strip the first single quote character
    local mark = string.sub(v.mark, 2, 3)
    local _, lnum, col, _ = unpack(v.pos)
    local name = local_marks.name_func(mark, lnum)
    -- same format to :marks command
    local line = string.format("%s %6d %4d %s", mark, lnum, col - 1, name)
    local row = {
      line = line,
      lnum = lnum,
      col = col,
      filename = utils.path_expand(v.file or bufname),
    }
    -- non alphanumeric marks goes to last
	print(mark)
    if mark:match "%w" then
      table.insert(marks_table, row)
    end
  end
  marks_table = vim.fn.extend(marks_table, marks_others)
  pickers
    .new({}, {
      prompt_title = "Marks",
      finder = finders.new_table {
        results = marks_table,
        entry_maker = make_entry.gen_from_marks({}),
      },
      previewer = conf.grep_previewer({}),
      sorter = conf.generic_sorter({}),
	  layout_strategy = "horizontal",
		layout_config = {
		  preview_width = 0.9, -- preview takes 40%, results take the rest
		  -- width = 0.8,
		  -- height = 0.6,
		},
      push_cursor_on_edit = true,
      push_tagstack_on_edit = true,
    })
    :find()
end

vim.keymap.set('n', '<leader>mm', local_marks, { desc = "Telescope: local marks" })
