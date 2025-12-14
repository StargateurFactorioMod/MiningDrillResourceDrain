local mdrd = require("lib")

local remove_mining_productivity = settings.startup["mdrd-remove-mining-productivity"].value
local icon_64 = "__MiningDrillResourceDrain__/icon_64.png"
local icon_size_64 = 64

local icon_128 = "__MiningDrillResourceDrain__/icon_128.png"
local icon_size_128 = 128

local effects = {
  {
    type = "nothing",
    icon = icon_64,
    icon_size = icon_size_64,
    effect_description = {
      "technology-effects.mining-drill-resource-drain",
      string.format("%.2f", 100 / mdrd.level_max),
      string.format("%.2f", mdrd.rdrp_by_level(50, 1)),
    },
  }
}

function localised_description_by_level(level)
  local localised_description = {"technology-description.mining-efficiency"}
  for name, mining_drill in pairs(data.raw["mining-drill"]) do
    local rdrp = mining_drill.resource_drain_rate_percent or 100
    localised_description = {
      "mdrd.mining-efficiency-info",
      localised_description,
      name,
      string.format("%.2f\n", mdrd.mining_effectiveness_by_level(rdrp, level)),
    }
  end
  return localised_description
end

data:extend({ {
  type = "technology",
  name = "mining-efficiency-1",
  localised_description = localised_description_by_level(1),
  icon = icon_128,
  icon_size = icon_size_128,
  effects = effects,
  prerequisites = { "automation-science-pack" },
  upgrade = true,
  show_levels_info = true,
  unit =
  {
    count = 100,
    ingredients =
    {
      { "automation-science-pack", 1 },
    },
    time = 60,
  },
} })

data:extend({ {
  type = "technology",
  name = "mining-efficiency-2",
  localised_description = localised_description_by_level(2),
  icon = icon_128,
  icon_size = icon_size_128,
  effects = effects,
  upgrade = true,
  show_levels_info = true,
  prerequisites = { "logistic-science-pack", "mining-efficiency-1" },
  unit =
  {
    count = 200,
    ingredients =
    {
      { "automation-science-pack", 1 },
      { "logistic-science-pack",   1 },
    },
    time = 60,
  }
} })

data:extend({ {
  type = "technology",
  name = "mining-efficiency-3",
  localised_description = localised_description_by_level(3),
  icon = icon_128,
  icon_size = icon_size_128,
  effects = effects,
  upgrade = true,
  show_levels_info = true,
  prerequisites = { "chemical-science-pack", "mining-efficiency-2" },
  unit =
  {
    count = 300,
    ingredients =
    {
      { "automation-science-pack", 1 },
      { "logistic-science-pack",   1 },
      { "chemical-science-pack",   1 },
    },
    time = 60,
  }
} })

data:extend({ {
  type = "technology",
  name = "mining-efficiency-4",
  localised_description = localised_description_by_level(4),
  icon = icon_128,
  icon_size = icon_size_128,
  effects = effects,
  upgrade = true,
  show_levels_info = true,
  prerequisites = { "production-science-pack", "mining-efficiency-3" },
  unit =
  {
    count = 400,
    ingredients =
    {
      { "automation-science-pack", 1 },
      { "logistic-science-pack",   1 },
      { "chemical-science-pack",   1 },
      { "production-science-pack", 1 },
    },
    time = 60,
  }
} })

data:extend({ {
  type = "technology",
  name = "mining-efficiency-5",
  localised_description = localised_description_by_level(5),
  icon = icon_128,
  icon_size = icon_size_128,
  effects = effects,
  upgrade = true,
  show_levels_info = true,
  prerequisites = { "utility-science-pack", "mining-efficiency-4" },
  unit =
  {
    count = 500,
    ingredients =
    {
      { "automation-science-pack", 1 },
      { "logistic-science-pack",   1 },
      { "chemical-science-pack",   1 },
      { "production-science-pack", 1 },
      { "utility-science-pack",    1 }
    },
    time = 60,
  }
} })

data:extend({ {
  type = "technology",
  name = "mining-efficiency-6",
  localised_description = localised_description_by_level(6),
  icon = icon_128,
  icon_size = icon_size_128,
  effects = effects,
  upgrade = true,
  show_levels_info = true,
  prerequisites = { "space-science-pack", "mining-efficiency-5" },
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
  }
} })

local hidden_mining_drills = {}


for level = 1, mdrd.level_max do
  local leter = mdrd.get_level(level)
  -- Prepare new drills
  for quality_name, quality in pairs(data.raw["quality"]) do
    if quality_name ~= "quality-unknown" then
      for name, mining_drill in pairs(data.raw["mining-drill"]) do
        local hidden_mining_drill = table.deepcopy(mining_drill)
        hidden_mining_drill.hidden = false
        local icons = hidden_mining_drill.icons or {{
            icon = hidden_mining_drill.icon,
            icon_size = hidden_mining_drill.icon_size,
        }}
        table.insert(icons, {
          icon = "__base__/graphics/icons/signal/signal_" .. leter .. ".png",
          icon_size = 64,
          scale = 0.25,
          shift = { 8, 8 },
        })
        table.insert(icons, {
          icon = quality.icon,
          icon_size = quality.icon_size,
          scale = 0.25,
          shift = { -8, 8 },
        })
        hidden_mining_drill.icons = icons
        hidden_mining_drill.hidden_in_factoriopedia = true
        hidden_mining_drill.placeable_by = { item = name, count = 1 }
        hidden_mining_drill.localised_name = { "entity-name." .. name }
        hidden_mining_drill.localised_description = { "entity-description." .. name }

        hidden_mining_drill.name = hidden_mining_drill.name .. "-mdrd" .. quality_name .. leter
        hidden_mining_drill.resource_drain_rate_percent = mdrd.rdrp_by_level(
          hidden_mining_drill.resource_drain_rate_percent or 100, level)
        hidden_mining_drill.mining_speed = hidden_mining_drill.mining_speed * (1 + quality.level * 0.3)
        local n, u = string.match(hidden_mining_drill.energy_usage, "(%d)(.*)")
        hidden_mining_drill.energy_usage = n * (1 + quality.level * 0.3) .. u

        table.insert(hidden_mining_drills, hidden_mining_drill)
      end
    end
  end

  if level > 6 then
    data:extend({ {
      type = "technology",
      name = "mining-efficiency-" .. level,
      localised_description = localised_description_by_level(level),
      icon = icon_128,
      icon_size = icon_size_128,
      effects = effects,
      upgrade = true,
      show_levels_info = true,
      prerequisites = { "mining-efficiency-" .. level - 1 },
      unit =
      {
        count = 3 ^ (level - 6) * 1000,
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
end

data.extend(hidden_mining_drills)

-- Remove mining productivity
if remove_mining_productivity then
  local i = 1
  while true do
    local technology_mining_productivity = data.raw["technology"]["mining-productivity-" .. i]
    if technology_mining_productivity then
      -- doesn't work soooo
      technology_mining_productivity.enabled = false
      technology_mining_productivity.visible_when_disabled = false
      -- boom
      data.raw["technology"]["mining-productivity-" .. i] = nil

      i = i + 1
    else
      break
    end
  end
end

-- remove drain resource bonus of mining drill
for _, quality in pairs(data.raw["quality"]) do
  quality.mining_drill_resource_drain_multiplier = 1
end
