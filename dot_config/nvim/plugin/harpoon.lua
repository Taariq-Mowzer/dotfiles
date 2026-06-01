local harpoon = require("harpoon")
local review = require("taariq.review")

-- REQUIRED
harpoon:setup({
    review = review.list_config(),
})
-- REQUIRED
-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
    }):find()
end

vim.keymap.set("n", "<leader>at", function() toggle_telescope(harpoon:list()) end,
    { desc = "Open harpoon window" })
vim.keymap.set("n", "<leader>aa", function() harpoon:list():add() end)
vim.keymap.set("n", "<leader>al", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set("n", "<leader>ad", review.open_menu, { desc = "Open review list" })

vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
