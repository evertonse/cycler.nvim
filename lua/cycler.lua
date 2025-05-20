local M = {}

local alternates = {
  ["true"] = "false",
  ["True"] = "False",
  ["TRUE"] = "FALSE",
  ["Yes"] = "No",
  ["YES"] = "NO",
  ["<"] = ">",
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ['"'] = "'",
  ['""'] = "''",
  ["+"] = "-",
  ["==="] = "!==",
  ["=="] = "!=",
}
local function_cyclers = {}

local function error_handler(err)
  if not err == nil then
    vim.notify("Error cycling values. Err: " .. err, vim.log.levels.ERROR)
  end
end

local toalternates = function(cycles)
  local alts = {}
  for _, cycle in ipairs(cycles) do
    if type(cycle) == "table" then
      for i = 1, #cycle - 1 do
        alts[tostring("" .. cycle[i])] = tostring(cycle[i + 1])
      end
      alts[tostring("" .. cycle[#cycle])] = tostring(cycle[1])
    elseif type(cycle) == "function" then
      table.insert(function_cyclers, cycle)
    else
      vim.notify("Fuck you doing trying to using " .. type(cycle) .. " as cycler", vim.log.levels.INFO)
    end
  end
  return alts
end

--TODO: Make the thingy go brr with allowing additional function such as cycle-next(previous) -> next | nil if nill than it wasnt a match and the order of next functions matter
M.setup = function(opts)
  if type(opts.cycles) == "table" then
    local alts = toalternates(opts.cycles)
    alternates = vim.tbl_extend("force", alternates, alts)
  end
end

local user_clipboard = nil
local user_register = nil
local user_register_mode = nil
local cursor = nil

local function snapshot_and_clean()
  user_clipboard = vim.o.clipboard
  user_register = vim.fn.getreg('"')
  user_register_mode = vim.fn.getregtype('"')
  cursor = vim.api.nvim_win_get_cursor(0)

  vim.o.clipboard = nil
end

local function restore_snapshot()
  vim.fn.setreg('"', user_register, user_register_mode)
  vim.o.clipboard = user_clipboard
  vim.api.nvim_win_set_cursor(0, cursor)
end

M.cycle = function()
  snapshot_and_clean()

  vim.cmd("normal! yiw")
  local yanked_word = vim.fn.getreg('"')
  local word = alternates[yanked_word]
  if yanked_word and yanked_word == " " then
    restore_snapshot()
    return
  end

  if word == nil then
    for _, func in ipairs(function_cyclers) do
      --- if a fucntion return nil its not a match
      word = func(yanked_word)
      if word ~= nil then
        break
      end
    end
  end

  if word == nil then
    vim.notify("Unsupported cycle value.", vim.log.levels.INFO)
    restore_snapshot()
    return
  end

  xpcall(function()
    vim.cmd("normal! ciw" .. word)
  end, error_handler)

  restore_snapshot()
  return
end

return M
