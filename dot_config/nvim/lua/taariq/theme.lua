vim.cmd.colorscheme 'tokyonight-night'

vim.api.nvim_set_hl(0, "Normal", {guibg=NONE})
vim.api.nvim_set_hl(0, "NormalNC", {guibg=NONE})

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.signcolumn = 'yes'

vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })

function _G.NeatFoldText()
  local line = " " .. vim.fn.substitute(
    vim.fn.getline(vim.v.foldstart),
    [[^\s*"\?\s*\|\s*"\?\s*{{\d*\s*]],
    "",
    "g"
  ) .. " "

  local lines_count = vim.v.foldend - vim.v.foldstart + 1
  local lines_count_text = "| " .. string.format("%10s", lines_count .. " lines") .. " |"

  local fillchars = vim.opt.fillchars:get()
  local foldchar = fillchars.fold or " "

  local foldtextstart = string.sub(
    "+" .. string.rep(foldchar, vim.v.foldlevel * 2) .. line,
    1,
    math.floor((vim.fn.winwidth(0) * 2) / 3)
  )

  local foldtextend = lines_count_text .. string.rep(foldchar, 8)

  local foldtextlength = vim.fn.strdisplaywidth(foldtextstart .. foldtextend) + vim.wo.foldcolumn
  local padding = math.max(vim.fn.winwidth(0) - foldtextlength, 0)

  return foldtextstart .. string.rep(" ", padding) .. foldtextend
end

vim.opt.foldtext = "v:lua.NeatFoldText()"
vim.opt.fillchars:append({diff = " "})
