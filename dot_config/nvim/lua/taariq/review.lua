local Path = require("plenary.path")
local harpoon = require("harpoon")

local M = {}

local REVIEW_LIST = "review"
local current_base = "master"

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO)
end

local function run_git(args, cwd)
    local result = vim.system(args, { cwd = cwd, text = true }):wait()
    local output = vim.trim(result.stdout or "")
    local err = vim.trim(result.stderr or "")

    return result.code, output, err
end

local function git_root()
    local code, output, err = run_git({ "git", "rev-parse", "--show-toplevel" })
    if code ~= 0 or output == "" then
        notify(err ~= "" and err or "Not inside a git repository", vim.log.levels.ERROR)
        return nil
    end

    return output
end

local function normalize_path(path, root)
    local trimmed = vim.trim(path or "")
    if trimmed == "" then
        return nil
    end

    return Path:new(root, trimmed):make_relative(root)
end

local function clear_layout()
    if #vim.api.nvim_tabpage_list_wins(0) <= 1 then
        return true
    end

    local ok, err = pcall(vim.cmd, "only")
    if not ok then
        notify("Could not reset window layout: " .. err, vim.log.levels.ERROR)
        return false
    end

    return true
end

local function open_review_diff(list_item)
    if not list_item then
        return
    end

    local root = git_root()
    if not root then
        return
    end

    local file = list_item.value
    local abs_path = Path:new(root, file):absolute()
    if vim.fn.filereadable(abs_path) == 0 then
        notify("Skipping missing file in review list: " .. file, vim.log.levels.WARN)
        return
    end

    if not clear_layout() then
        return
    end

    vim.cmd("lcd " .. vim.fn.fnameescape(root))
    vim.cmd("edit " .. vim.fn.fnameescape(file))

    local ok, err = pcall(vim.cmd, "leftabove Gvdiffsplit " .. vim.fn.fnameescape(current_base))
    if not ok then
        notify("Failed to open Fugitive diff for " .. file .. ": " .. err, vim.log.levels.ERROR)
    end
end

function M.list_config()
    return {
        encode = false,
        create_list_item = function(_, item)
            return {
                value = item,
                context = {},
            }
        end,
        select = function(list_item)
            open_review_diff(list_item)
        end,
    }
end

function M.list()
    return harpoon:list(REVIEW_LIST)
end

function M.open_menu()
    harpoon.ui:toggle_quick_menu(M.list(), { title = "Review" })
end

function M.clear()
    M.list():clear()
end

function M.populate(files)
    local list = M.list()
    list:clear()

    for _, file in ipairs(files) do
        list:add({
            value = file,
            context = {},
        })
    end
end

function M.run(base_branch)
    local base = base_branch ~= nil and vim.trim(base_branch) ~= "" and vim.trim(base_branch) or "master"
    local root = git_root()
    if not root then
        return
    end

    -- local exists_code = vim.system(
    --     { "git", "show-ref", "--verify", "--quiet", "refs/heads/" .. base },
    --     { cwd = root }
    -- ):wait().code
    --
    -- if exists_code ~= 0 then
    --     notify("Base branch does not exist locally: " .. base, vim.log.levels.ERROR)
    --     return
    -- end

    current_base = base

    local code, output, err = run_git(
        { "git", "diff", "--name-only", "--diff-filter=d", base .. "...HEAD" },
        root
    )

    if code ~= 0 then
        notify(
            err ~= "" and err or ("git diff failed against " .. base),
            vim.log.levels.ERROR
        )
        return
    end

    local files = {}
    for _, line in ipairs(vim.split(output, "\n", { trimempty = true })) do
        local normalized = normalize_path(line, root)
        if normalized then
            table.insert(files, normalized)
        end
    end

    M.populate(files)

    if #files == 0 then
        notify("No changed files found against " .. base)
        return
    end

    notify("Loaded " .. #files .. " review file(s) against " .. base)
    M.open_menu()
end

return M
