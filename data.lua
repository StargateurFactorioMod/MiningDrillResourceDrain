local mdrd = require("mdrd")
local util = require("util")

-- Add technology
local tech_icon = "__base__/graphics/technology/mining-productivity.png"
local effects = {
  {
    type = "nothing",
    icons = { {
      icon = tech_icon,
      icon_size = 256,
    }, {
      icon = "__core__/graphics/icons/technology/effect-constant/effect-constant-mining-productivity.png",
      icon_size = 64,
    } },
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
  prerequisites = { "production-science-pack" },
  upgrade = true,
  unit =
  {
    count = 2^16,
    ingredients =
    {
      { "automation-science-pack", 1 },
      { "logistic-science-pack",   1 },
      { "chemical-science-pack",   1 },
      { "production-science-pack", 1 },
    },
    time = 30,
  },
} })

data:extend({ {
  type = "technology",
  name = "mining-efficiency-2",
  icons = tech_icons,
  effects = effects,
  prerequisites = { "utility-science-pack", "mining-efficiency-1" },
  upgrade = true,
  unit =
  {
    count = 2^20,
    ingredients =
    {
      { "automation-science-pack", 1 },
      { "logistic-science-pack",   1 },
      { "chemical-science-pack",   1 },
      { "production-science-pack", 1 },
      { "utility-science-pack",    1 },
    },
    time = 45,
  },
} })

data:extend({ {
  type = "technology",
  name = "mining-efficiency-3",
  icons = tech_icons,
  effects = effects,
  prerequisites = { "space-science-pack", "mining-efficiency-2" },
  upgrade = true,
  unit =
  {
    count = 2^22,
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

data:extend({ {
  type = "technology",
  name = "mining-efficiency-4",
  icons = tech_icons,
  effects = effects,
  prerequisites = { "mining-efficiency-3" },
  upgrade = true,
  unit =
  {
    count = 2^24,
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

data:extend({ {
  type = "technology",
  name = "mining-efficiency-5",
  icons = tech_icons,
  effects = effects,
  prerequisites = { "mining-efficiency-4" },
  upgrade = true,
  unit =
  {
    count = 2^26,
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

data:extend({ {
  type = "technology",
  name = "mining-efficiency-6",
  icons = tech_icons,
  effects = effects,
  prerequisites = { "mining-efficiency-5" },
  upgrade = true,
  unit =
  {
    count = 2^28,
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

data:extend({ {
  type = "technology",
  name = "mining-efficiency-7",
  icons = tech_icons,
  effects = effects,
  prerequisites = { "mining-efficiency-6" },
  upgrade = true,
  unit =
  {
    count = 2^29,
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
