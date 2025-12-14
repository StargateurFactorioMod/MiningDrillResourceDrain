local mdrd = require("lib")

local filter_mining_drill = { filter = "type", type = "mining-drill" }

local UPGRADE_NOOP = 0
local UPGRADE_SUCCESS = 1
local UPGRADE_FAIL = 2

script.on_init(function()
  storage.forces = {}
end)

function upgrade_force(force, level)
  local result = {
    success = 0,
    fail = 0,
    noop = 0,
  }

  for _, surface in pairs(game.surfaces) do
    for _, mining_drill in ipairs(surface.find_entities_filtered { type = "mining-drill", force = force }) do
      local x = upgrade(mining_drill, level)
      if x == UPGRADE_NOOP then
        result.noop = result.noop + 1
      elseif x == UPGRADE_SUCCESS then
        result.success = result.success + 1
      elseif x == UPGRADE_FAIL then
        result.fail = result.fail + 1
      else
        log("mdrd: upgrade() return unexpected value")
      end
    end
  end

  force.print(string.format("mdrd: success %d ,fail %d, noop %d", result.success, result.fail, result.noop))
end

function get_base_name(name)
  return string.match(name, "^(.*)%-mdrd.*$")
end

function is_normal_mining_drill(name)
  return not get_base_name(name)
end

function upgrade(mining_drill, level)
  local name = get_base_name(mining_drill.name) or mining_drill.name
  if level then
    name = name .. "-mdrd" .. mining_drill.quality.name .. mdrd.get_level(level)
  end

  if name == mining_drill.name then
    return UPGRADE_NOOP
  elseif mining_drill.order_upgrade({
        target = {
          name = name,
          quality = mining_drill.quality
        },
        force = mining_drill.force,
      }) then
    mining_drill.force.print(string.format("mdrd: upgrade %s to %s", mining_drill.name, name))
    local a, b = mining_drill.apply_upgrade()
    return UPGRADE_SUCCESS
  else
    mining_drill.force.print(string.format("mdrd: can't upgrade %s to %s", mining_drill.name, name))
    return UPGRADE_FAIL
  end
end

commands.add_command("mdrd_refresh", "Opposite of mdrd_reset will put back special mining drill entities", function(command)
  for name, force in pairs(game.forces) do
    local level
    for i = 1, mdrd.level_max do
      local tech = force.technologies["mining-efficiency-" .. i]
      if not tech.researched then
        break
      else
        level = i
      end
    end
    storage.forces[name] = level
    upgrade_force(force, storage.forces[name])
  end
end)

commands.add_command("mdrd_unresearch",
"UnResearch the Mining Drill Resource Drain tech. If you want to remove this mod use this before",
function(_)
  for name, force in pairs(game.forces) do
    for i = 1, mdrd.level_max do
      local tech = force.technologies["mining-efficiency-" .. i]
      tech.researched = false
      storage.forces[name] = nil
    end
    upgrade_force(force, nil)
  end
  storage.forces = {}
end)

commands.add_command("mdrd_list_effects",
"Show by how many each mining drill multiply resource",
function(command)
  local player = game.get_player(command.player_index)
  if player then
    local level = storage.forces[player.force.name] or 0
    for name, mining_drill in pairs(prototypes.get_entity_filtered { filter_mining_drill }) do
      if is_normal_mining_drill(name) then
        local rdrp = mining_drill.resource_drain_rate_percent or 100
        local effectiveness = mdrd.mining_effectiveness_by_level(rdrp, level)
        player.print({"mdrd.mining-efficiency-info", "", name, string.format("%.2f", effectiveness)})
      end
    end
  end
end)

commands.add_command("mdrd_reset",
"Opposite of mdrd_refresh will put back all mining drill to normal entities without unresearch the tech",
function(_)
  for _, force in pairs(game.forces) do
    upgrade_force(force, nil)
  end
end)

local on_built = function(event)
  local entity = event.entity
  local level = storage.forces[entity.force.name]
  upgrade(entity, level)
end

script.on_event(defines.events.on_research_finished, function(event)
  local research = event.research
  local name, level = string.match(research.name, "^(.-)%-(%d+)$")
  if name == "mining-efficiency" then
    local force = research.force
    storage.forces[force.name] = level
    upgrade_force(force, level)
  end
end)

script.on_event(defines.events.on_built_entity, on_built, { filter_mining_drill })
script.on_event(defines.events.on_robot_built_entity, on_built, { filter_mining_drill })
