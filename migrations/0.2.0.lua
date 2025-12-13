local save = {}
for force, level in pairs(storage.forces) do
  save[force] = level
  level = 0
end
upgrade_all_forces()
for force, level in pairs(storage.forces) do
  level = save[force]
end
upgrade_all_forces()

local level_max = settings.startup["mining-drill-resource-drain-max-level"].value

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

function upgrade(mining_drill)
  local level = storage.forces[mining_drill.force.name]
  local base_name = mining_drill.prototype.items_to_place_this[1].name
  local name
  if level then
    name = base_name .. "-" .. mining_drill.quality.name .. "-" .. level
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

function upgrade_all_forces()
    for _, force in pairs(game.forces) do
    local result = update_force_to_current_level(force)
    force.print(string.format("updated %d mining drill, fail to update %d mining drill", result.success, result.fail))
  end
end

function reset_all_level()
  for _, force in pairs(game.forces) do
    for i = 1, level_max do
      local tech = force.technologies["mining-drill-resource-drain-" .. i]
      tech.researched = false
    end
  end
  storage.forces = {}
end
