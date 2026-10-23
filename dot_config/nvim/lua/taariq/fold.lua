local function folds_at_line(line)
  local folds = {}
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, { line, 0 })

  local closed_first = vim.fn.foldclosed(line)
  local closed_last = vim.fn.foldclosedend(line)
  if closed_first ~= -1 then
    vim.cmd("normal! zO")
  end

  local depth = vim.fn.foldlevel(line)
  -- Closing each depth briefly reveals boundaries that foldlevel() cannot distinguish.
  for count = 1, depth do
    vim.cmd(("normal! %dzc"):format(count))
    folds[#folds + 1] = {
      first = vim.fn.foldclosed(line),
      last = vim.fn.foldclosedend(line),
      depth = depth - count + 1,
    }
    vim.cmd(("normal! %dzo"):format(count))
  end

  if closed_first ~= -1 then
    for count = depth, 1, -1 do
      local fold = folds[count]
      if fold.first == closed_first and fold.last == closed_last then
        vim.cmd(("normal! %dzc"):format(count))
        break
      end
    end
  end

  vim.api.nvim_win_set_cursor(0, cursor)
  return folds
end

local function fold_outside_selection(first, last)
  if first > last then
    first, last = last, first
  end

  local line_count = vim.api.nvim_buf_line_count(0)
  vim.wo.foldminlines = 0
  local folds = folds_at_line(first)
  vim.list_extend(folds, folds_at_line(last))
  local parent

  for _, fold in ipairs(folds) do
    local intersects = fold.first <= last and first <= fold.last
    local contains_selection = fold.first <= first and last <= fold.last
    local selection_contains_fold = first <= fold.first and fold.last <= last

    if intersects and not contains_selection and not selection_contains_fold then
      vim.notify("zp: selection crosses a fold boundary", vim.log.levels.ERROR)
      return
    end

    if contains_selection and (not parent or fold.depth > parent.depth) then
      parent = fold
    end
  end

  local scope_first = parent and parent.first or 1
  local scope_last = parent and parent.last or line_count

  if parent then
    local delete_at
    for line = parent.first, parent.last do
      if vim.fn.foldlevel(line) == parent.depth then
        delete_at = line
        break
      end
    end
    if not delete_at then
      delete_at = parent.first
      vim.api.nvim_win_set_cursor(0, { delete_at, 0 })
      vim.cmd("normal! zO")
      vim.cmd(("normal! %dzc"):format(vim.fn.foldlevel(delete_at) - parent.depth + 1))
    else
      vim.api.nvim_win_set_cursor(0, { delete_at, 0 })
    end

    vim.cmd("normal! zd")
  end

  if scope_first < first then
    vim.cmd(("%d,%dfold"):format(scope_first, first - 1))
  end
  if last < scope_last then
    vim.cmd(("%d,%dfold"):format(last + 1, scope_last))
  end
end

vim.keymap.set("x", "zp", function()
  local first = vim.fn.getpos("v")[2]
  local cursor = vim.api.nvim_win_get_cursor(0)
  local last = cursor[1]
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  fold_outside_selection(first, last)
  vim.api.nvim_win_set_cursor(0, cursor)
end, { desc = "Fold lines outside visual selection" })
