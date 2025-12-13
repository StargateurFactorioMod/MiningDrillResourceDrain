local level_max = settings.startup["mdrd-max-level"].value
local remove_mining_productivity = settings.startup["mdrd-remove-mining-productivity"].value
local icon = "__MiningDrillResourceDrain__/thumbnail.png"
local icon_size = 1024

local effects = {
  {
    type = "nothing",
    icon = icon,
    icon_size = icon_size,
    effect_description = {
      "technology-effects.mining-drill-resource-drain",
      tostring(100 / level_max),
    },
  }
}

data:extend({ {
  type = "technology",
  name = "mining-drill-resource-drain-1",
  icon = icon,
  icon_size = icon_size,
  effects = effects,
  prerequisites = { "automation-science-pack" },
  upgrade = true,
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
  name = "mining-drill-resource-drain-2",
  icon = icon,
  icon_size = icon_size,
  effects = effects,
  upgrade = true,
  prerequisites = { "logistic-science-pack", "mining-drill-resource-drain-1" },
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
  name = "mining-drill-resource-drain-3",
  icon = icon,
  icon_size = icon_size,
  effects = effects,
  upgrade = true,
  prerequisites = { "chemical-science-pack", "mining-drill-resource-drain-2" },
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
  name = "mining-drill-resource-drain-4",
  icon = icon,
  icon_size = icon_size,
  effects = effects,
  upgrade = true,
  prerequisites = { "production-science-pack", "mining-drill-resource-drain-3" },
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
  name = "mining-drill-resource-drain-5",
  icon = icon,
  icon_size = icon_size,
  effects = effects,
  upgrade = true,
  prerequisites = { "utility-science-pack", "mining-drill-resource-drain-4" },
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
  name = "mining-drill-resource-drain-6",
  icon = icon,
  icon_size = icon_size,
  effects = effects,
  upgrade = true,
  prerequisites = { "space-science-pack", "mining-drill-resource-drain-5" },
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

for level = 1, level_max do
  -- Prepare new drills
  for quality_name, quality in pairs(data.raw["quality"]) do
    if quality_name ~= "quality-unknown" then
      for name, mining_drill in pairs(data.raw["mining-drill"]) do
        local hidden_mining_drill = table.deepcopy(mining_drill)
        hidden_mining_drill.hidden = false
        hidden_mining_drill.icon = icon
        hidden_mining_drill.icon_size = icon_size
        hidden_mining_drill.hidden_in_factoriopedia = true
        hidden_mining_drill.placeable_by = { item = name, count = 1 }
        hidden_mining_drill.localised_name = { "entity-name." .. name }
        hidden_mining_drill.localised_description = { "entity-description." .. name }
        hidden_mining_drill.name = hidden_mining_drill.name .. "-mdrd" .. quality_name .. level
        local rdrp = hidden_mining_drill.resource_drain_rate_percent or 100
        local new_rdrp = rdrp - ((rdrp / level_max) * level)
        if new_rdrp == 0 then
          new_rdrp = 1
        end
        hidden_mining_drill.resource_drain_rate_percent = new_rdrp
        hidden_mining_drill.mining_speed = hidden_mining_drill.mining_speed * (1 + quality.level * 0.3)

        table.insert(hidden_mining_drills, hidden_mining_drill)
      end
    end
  end

  if level > 6 then
    data:extend({ {
      type = "technology",
      name = "mining-drill-resource-drain-" .. level,
      icon = icon,
      icon_size = icon_size,
      effects = effects,
      upgrade = true,
      prerequisites = { "mining-drill-resource-drain-" .. level - 1 },
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
