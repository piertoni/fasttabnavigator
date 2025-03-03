local function rightMostWindowWinCols()
  local tabid = vim.api.nvim_get_current_tabpage()
  local tabinfo = vim.fn.gettabinfo(tabid)[1]
  local wincolsmax = {}
  for i = 1, #tabinfo.windows do
    local winid = tabinfo.windows[i]
    local wininfo = vim.fn.getwininfo(winid)[1]
    table.insert(wincolsmax, wininfo.wincol + wininfo.width)
  end
  return math.max(unpack(wincolsmax))
end

local function moveToLeftWindowOrPreviousTab()
  local winid = vim.api.nvim_get_current_win()
  local wininfo = vim.fn.getwininfo(winid)[1]
  if wininfo.wincol == 1 then
    vim.cmd('tabprevious')
  else
    vim.cmd('wincmd h')
  end
end

local function moveToRightWindowOrNextTab()
  local winid = vim.api.nvim_get_current_win()
  local wininfo = vim.fn.getwininfo(winid)[1]
  local winColMax = rightMostWindowWinCols()
  if wininfo.wincol + wininfo.width == winColMax then
    vim.cmd('tabnext')
  else
    vim.cmd('wincmd l')
  end
end

vim.keymap.set('n', '<C-l>', function()
  moveToRightWindowOrNextTab()
end, { noremap = true, silent = true })

vim.keymap.set('n', '<C-h>', function()
  moveToLeftWindowOrPreviousTab()
end, { noremap = true, silent = true })
