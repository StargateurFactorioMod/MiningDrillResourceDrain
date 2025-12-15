local mdrd = require("mdrd")

-- Add technology
local tech_icon = "__base__/graphics/technology/mining-productivity.png"
local effects = {
  {
    type = "nothing",
    icons = {{
      icon = tech_icon,
      icon_size = 256,
    }, {
      icon = "__core__/graphics/icons/technology/effect-constant/effect-constant-mining-productivity.png",
      icon_size = 64,
    }},
    effect_description = {
      "technology-effects.mining-drill-resource-drain",
    },
  }
}
local tech_icons = util.technology_icon_constant_productivity(tech_icon)
data:extend({ {
  type = "technology",
  name = "mining-efficiency-1",
  icons = tech_icons,
  effects = effects,
  prerequisites = { "space-science-pack" },
  upgrade = true,
  unit =
  {
    count = 1000,
    ingredients =
    {
      { "automation-science-pack", 1 },
      { "logistic-science-pack",   1 },
      { "chemical-science-pack",   1 },
      { "production-science-pack", 1 },
      { "utility-science-pack",    1 },
      { "space-science-pack",      1 },
    },
    time = 60,
  },
} })
for level = 2, mdrd.level_max do
    local previous_level = level - 1
    data:extend({ {
      type = "technology",
      name = "mining-efficiency-" .. level,
      icons = tech_icons,
      effects = effects,
      upgrade = true,
      prerequisites = { "mining-efficiency-" .. previous_level },
      unit =
      {
        count = 1000 * (10 ^ previous_level),
        ingredients =
        {
          { "automation-science-pack", 1 },
          { "logistic-science-pack",   1 },
          { "chemical-science-pack",   1 },
          { "production-science-pack", 1 },
          { "utility-science-pack",    1 },
          { "space-science-pack",      1 },
        },
        time = 60,
      }
    } })
end

-- Prepare new drills
local mdrd_mining_drills = {}
for quality_name, quality in pairs(data.raw["quality"]) do
  if quality_name ~= "quality-unknown" then
    for name, mining_drill in pairs(data.raw["mining-drill"]) do
      if not mdrd.ignore_list[name] then
        mining_drill.resource_drain_rate_percent = 100
        for level = 1, mdrd.level_max do
          local mdrd_mining_drill = table.deepcopy(mining_drill)
          mdrd_mining_drill.name = mdrd.mining_name(mdrd_mining_drill.name,  quality_name, level)
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
            {"entity-description." .. name},
            "\n",
            {"mdrd.entity-icon", mdrd_mining_drill.name},
            ".",
          }
          local rdrp = mdrd.rdrp_by_level(mdrd_mining_drill.resource_drain_rate_percent, level)
          mdrd_mining_drill.resource_drain_rate_percent = rdrp
          mdrd_mining_drill.mining_speed = mdrd_mining_drill.mining_speed * (1 + quality.level * 0.3)
          local n, u = string.match(mdrd_mining_drill.energy_usage, "(%d+)(.+)")
          mdrd_mining_drill.energy_usage = n * (1 + quality.level * 0.3) .. u
          table.insert(mdrd_mining_drills, mdrd_mining_drill)
        end
      end
    end
  end
end

data.extend(mdrd_mining_drills)

-- Remove mining productivity
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

-- remove drain resource quality effects of mining drill
for _, quality in pairs(data.raw["quality"]) do
  quality.mining_drill_resource_drain_multiplier = 1
end
