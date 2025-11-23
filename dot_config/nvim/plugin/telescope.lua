local builtin = require('telescope.builtin')
local action_state = require('telescope.actions.state')
local actions = require('telescope.actions')

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
	
vim.keymap.set('n', '<leader>bb', buffer_searcher, {})
vim.keymap.set('n', '<leader>bl', ':LS<CR>:b ', { noremap = true })
