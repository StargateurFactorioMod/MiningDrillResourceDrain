local level_max = settings.startup["mining-drill-resource-drain-max-level"].value

local filter_mining_drill = { filter = "type", type = "mining-drill" }

script.on_init(function()
  storage.forces = {}
end)

function update_force_to_current_level(force)
  local result = {
    success = 0,
    fail = 0,
  }

  for _, surface in pairs(game.surfaces) do
    for _, mining_drill in ipairs(surface.find_entities_filtered { type = "mining-drill", force = force }) do
      if upgrade(mining_drill) then
        result.success = result.success + 1
      else
        result.fail = result.fail + 1
      end
    end
  end

  return result
end

script.on_event(defines.events.on_research_finished, function(event)
  local research = event.research
  local name, level = string.match(research.name, "^(.-)%-(%d+)$")
  if name == "mining-drill-resource-drain" then
    local force = research.force
    storage.forces[force.name] = level
    update_force_to_current_level(force)
  end
end)

function upgrade(mining_drill)
  local level = storage.forces[mining_drill.force.name]
  local base_name = mining_drill.prototype.items_to_place_this[1].name
  local name
  if level then
    name = "mining-drill-resource-drain-" .. base_name .. "-" .. level
  else
    name = base_name
  end

  if mining_drill.order_upgrade({
    target = {
      name = name,
      quality = mining_drill.quality
    },
    force = mining_drill.force,
  }) then
    mining_drill.apply_upgrade()
    return true
  else
    log("can't upgrade")
    log(serpent.block(mining_drill))
    return false
  end

end

local on_built = function(event)
  local entity = event.entity
  local level = storage.forces[entity.force.name]
  if level then
    upgrade(entity)
  end
end

script.on_event(defines.events.on_built_entity, on_built, { filter_mining_drill })
script.on_event(defines.events.on_robot_built_entity, on_built, { filter_mining_drill })

function refresh_all_level()
  for name, force in pairs(game.forces) do
    local level
    for i = 1, level_max do
      local tech = force.technologies["mining-drill-resource-drain-" .. i]
      if not tech.researched then
        break
      else
        level = i
      end
    end
    storage.forces[name] = level
  end
end

commands.add_command("mdrd_refresh", "In case of bugs try this", function(command)
  refresh_all_level()
  for _, force in pairs(game.forces) do
    local result = update_force_to_current_level(force)
    force.print(string.format("updated %d mining drill, fail to update %d mining drill", result.success, result.fail))
  end
end)

function reset_all_level()
  for _, force in pairs(game.forces) do
    for i = 1, level_max do
      local tech = force.technologies["mining-drill-resource-drain-" .. i]
      tech.researched = false
    end
  end
  storage.forces = {}
end

commands.add_command("mdrd_unresearch",
"UnResearch the Mining Drill Resource Drain tech. If you want to remove this mod use this before",
function()
  reset_all_level()
  for _, force in pairs(game.forces) do
    local result = update_force_to_current_level(force)
    force.print(string.format("updated %d mining drill, fail to update %d mining drill", result.success, result.fail))
  end
end)