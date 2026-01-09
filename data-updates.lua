local mdrd = require("mdrd")
local util = require("util")

-- Prepare new drills
local mdrd_mining_drills = {}
for quality_name, quality in pairs(data.raw["quality"]) do
  if quality_name ~= "quality-unknown" then
    -- remove drain resource quality effects of mining drill
    if mods["quality"] then
      quality.mining_drill_resource_drain_multiplier = 1
    end

    for name, mining_drill in pairs(data.raw["mining-drill"]) do
      if not mdrd.ignore_list[name] then
        -- set mining drill to rdrp 100 and buff quality effect of mining drill
        if mods["quality"] then
          mining_drill.quality_affects_mining_radius = true
          mining_drill.quality_affects_module_slots = true
        end
        mining_drill.resource_drain_rate_percent = 100

        for level = 0, mdrd.level_max do
          local mdrd_mining_drill = table.deepcopy(mining_drill)
          mdrd_mining_drill.name = mdrd.mining_name(mdrd_mining_drill.name, quality_name, level)
          local icons = mdrd_mining_drill.icons or { {
            icon = mdrd_mining_drill.icon,
            icon_size = mdrd_mining_drill.icon_size,
          } }
          table.insert(icons, {
            icon = "__MiningDrillResourceDrain__/graphics/" .. level .. ".png",
            icon_size = 64,
          })
          table.insert(icons, {
            icon = quality.icon,
            icon_size = quality.icon_size,
            scale = 0.25,
            shift = { -8, 8 },
          })
          mdrd_mining_drill.icons = icons
          mdrd_mining_drill.hidden_in_factoriopedia = true
          mdrd_mining_drill.placeable_by = { item = name, count = 1 }
          mdrd_mining_drill.localised_name = { "entity-name." .. name }
          mdrd_mining_drill.localised_description = {
            "",
            { "entity-description." .. name },
            "\n",
            { "mdrd.entity-icon",           mdrd_mining_drill.name },
            ".",
          }
          local rdrp = mdrd.rdrp_by_level(mdrd_mining_drill.resource_drain_rate_percent, level)
          mdrd_mining_drill.resource_drain_rate_percent = rdrp
          mdrd_mining_drill.mining_speed = mdrd_mining_drill.mining_speed * (1 + quality.level * 0.3)
          local energy = util.parse_energy(mdrd_mining_drill.energy_usage)
          mdrd_mining_drill.energy_usage = energy * (1 + quality.level * 0.3) .. "J"
          table.insert(mdrd_mining_drills, mdrd_mining_drill)
        end
      end
    end
  end
end

data.extend(mdrd_mining_drills)
