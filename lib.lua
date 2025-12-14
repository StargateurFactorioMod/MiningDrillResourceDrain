local M = {}

M.leters = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
M.level_max = settings.startup["mdrd-max-level"].value

function M.rdrp_by_level(base, level) 
  local rdrp = base - ((base / M.level_max) * level)
  if rdrp == 0 then
    return 1
  else
    return rdrp
  end
end

function M.mining_effectiveness_by_level(base, level)
  return 100 / M.rdrp_by_level(base, level)
end

function M.get_level(level)
  return M.leters:sub(level, level)
end

return M