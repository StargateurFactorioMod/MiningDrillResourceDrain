local mdrd = require("mdrd")
local util = require("util")

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
