-- Restituisce la colonna dello schermo corrispondente al bordo destro
-- della finestra più a destra nella tab corrente.
-- Ritorna 0 se le informazioni sulla tab/finestra non possono essere recuperate
-- o se non ci sono finestre nella tab.
local function rightMostWindowWinCols()
  local tabid = vim.api.nvim_get_current_tabpage()
  local tab_info_list = vim.fn.gettabinfo(tabid)

  -- 1. Controlla se la tab page esiste
  if #tab_info_list == 0 then
    -- vim.notify("rightMostWindowWinCols: Tab " .. tabid .. " non trovata.", vim.log.levels.WARN)
    return 0
  end
  local tabinfo = tab_info_list[1]

  -- 2. Controlla se tabinfo è valido e contiene una tabella 'windows' non vuota
  if not tabinfo or type(tabinfo.windows) ~= 'table' or #tabinfo.windows == 0 then
    -- vim.notify("rightMostWindowWinCols: Nessuna finestra valida trovata nella tab " .. tabid, vim.log.levels.WARN)
    return 0 -- Nessuna finestra nella tab
  end

  local wincolsmax = {}
  -- Itera sulle finestre della tab
  for _, winid in ipairs(tabinfo.windows) do -- Usa ipairs per iterare su liste/sequenze
    local win_info_list = vim.fn.getwininfo(winid)

    -- 3. Controlla se la finestra esiste e le info sono state recuperate
    if #win_info_list > 0 then
      local wininfo = win_info_list[1]
      -- 4. Controlla che i campi necessari (wincol, width) esistano e siano numeri
      if wininfo and type(wininfo.wincol) == 'number' and type(wininfo.width) == 'number' then
        table.insert(wincolsmax, wininfo.wincol + wininfo.width)
      else
        -- vim.notify("rightMostWindowWinCols: wininfo non valido per finestra " .. winid, vim.log.levels.WARN)
      end
    else
      -- vim.notify("rightMostWindowWinCols: Finestra " .. winid .. " non trovata.", vim.log.levels.WARN)
    end
  end

  -- 5. Controlla se sono state trovate colonne valide
  if #wincolsmax == 0 then
    -- vim.notify("rightMostWindowWinCols: Nessuna colonna valida calcolata.", vim.log.levels.WARN)
    return 0
  end

  -- 6. Calcola il massimo in modo sicuro (anche se #wincolsmax > 0 dovrebbe bastare)
  local ok, max_col = pcall(math.max, unpack(wincolsmax))
  if not ok then
    -- vim.notify("rightMostWindowWinCols: Errore chiamando math.max.", vim.log.levels.ERROR)
    return 0
  end
  return max_col
end

-- Si sposta alla finestra a sinistra o alla tab precedente
local function moveToLeftWindowOrPreviousTab()
  local winid = vim.api.nvim_get_current_win()
  local win_info_list = vim.fn.getwininfo(winid)

  -- 1. Controlla se le info della finestra corrente sono valide
  if #win_info_list == 0 then
    -- vim.notify("moveToLeftWindowOrPreviousTab: Finestra corrente " .. winid .. " non trovata.", vim.log.levels.WARN)
    return -- Non fare nulla se la finestra corrente non è valida
  end
  local wininfo = win_info_list[1]

  -- 2. Controlla se wincol è valido
  if not wininfo or type(wininfo.wincol) ~= 'number' then
    -- vim.notify("moveToLeftWindowOrPreviousTab: wininfo non valido per finestra corrente " .. winid, vim.log.levels.WARN)
    return -- Non fare nulla se le info non sono valide
  end

  -- 3. Logica di spostamento
  if wininfo.wincol == 1 then
    -- Passa alla tab precedente solo se esiste più di una tab
    if vim.fn.tabpagenr('$') > 1 then
       -- Usa pcall per eseguire il comando in sicurezza (evita errori se fallisce)
       pcall(vim.cmd, 'tabprevious')
    -- else
      -- vim.notify("moveToLeftWindowOrPreviousTab: Nessuna tab precedente.", vim.log.levels.INFO)
    end
  else
    -- Usa pcall per eseguire il comando in sicurezza
    pcall(vim.cmd, 'wincmd h')
  end
end

-- Si sposta alla finestra a destra o alla tab successiva
local function moveToRightWindowOrNextTab()
  local winid = vim.api.nvim_get_current_win()
  local win_info_list = vim.fn.getwininfo(winid)

  -- 1. Controlla se le info della finestra corrente sono valide
  if #win_info_list == 0 then
    -- vim.notify("moveToRightWindowOrNextTab: Finestra corrente " .. winid .. " non trovata.", vim.log.levels.WARN)
    return -- Non fare nulla se la finestra corrente non è valida
  end
  local wininfo = win_info_list[1]

  -- 2. Controlla se i campi necessari sono validi
  if not wininfo or type(wininfo.wincol) ~= 'number' or type(wininfo.width) ~= 'number' then
    -- vim.notify("moveToRightWindowOrNextTab: wininfo non valido per finestra corrente " .. winid, vim.log.levels.WARN)
    return -- Non fare nulla se le info non sono valide
  end

  -- Ottieni la colonna massima (potrebbe essere 0 se ci sono stati problemi)
  local winColMax = rightMostWindowWinCols()

  -- 3. Logica di spostamento
  -- Controlla se la finestra corrente è la più a destra E se winColMax è valido (> 0)
  if winColMax > 0 and (wininfo.wincol + wininfo.width == winColMax) then
    -- Passa alla tab successiva solo se esiste più di una tab
    if vim.fn.tabpagenr('$') > 1 then
       -- Usa pcall per eseguire il comando in sicurezza
       pcall(vim.cmd, 'tabnext')
    -- else
      -- vim.notify("moveToRightWindowOrNextTab: Nessuna tab successiva.", vim.log.levels.INFO)
    end
  else
    -- Se non siamo nella finestra più a destra, o se winColMax è 0 (errore), prova a spostarti a destra.
    -- Usa pcall per eseguire il comando in sicurezza
    pcall(vim.cmd, 'wincmd l')
  end
end

-- Imposta le keymap
vim.keymap.set('n', '<C-l>', function()
  moveToRightWindowOrNextTab()
end, { noremap = true, silent = true, desc = "Sposta a finestra destra o tab successiva" })

vim.keymap.set('n', '<C-h>', function()
  moveToLeftWindowOrPreviousTab()
end, { noremap = true, silent = true, desc = "Sposta a finestra sinistra o tab precedente" })

print("Plugin navigazione finestra/tab caricato.") -- Messaggio opzionale per conferma
