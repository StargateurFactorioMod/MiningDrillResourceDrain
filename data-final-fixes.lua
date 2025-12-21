local mdrd = require("mdrd")
local util = require("util")

-- Remove mining productivity tech
if mdrd.remove_mining_productivity then
  local i = 1
  while true do
    local technology_mining_productivity = data.raw["technology"]["mining-productivity-" .. i]
    if technology_mining_productivity then
      data.raw["technology"]["mining-productivity-" .. i] = nil
      i = i + 1
    else
      break
    end
  end
end
