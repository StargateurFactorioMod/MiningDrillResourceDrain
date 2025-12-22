local mdrd = {}

mdrd.level_max = 7
mdrd.debug = false
mdrd.remove_mining_productivity = settings.startup["mdrd-remove-mining-productivity"].value
mdrd.ignore_list = {}
---@diagnostic disable-next-line: param-type-mismatch
for v in settings.startup["mdrd-ignore-list"].value:gmatch("([^,]+)") do
  v = v:match("^%s*(.-)%s*$")
  mdrd.ignore_list[v] = {}
end

mdrd.UPGRADE_NOOP = 0
mdrd.UPGRADE_SUCCESS = 1
mdrd.UPGRADE_FAIL = 2

function mdrd.print_debug(force, s)
  if mdrd.debug then
    force.print(s)
  end
end

function mdrd.rdrp_by_level(base, level) 
  local rdrp = base * 0.5 ^ level
  if rdrp < 1 then
    return 1
  else
    return math.ceil(rdrp)
  end
end

function mdrd.mining_effectiveness_by_level(base, level)
  return 100 / mdrd.rdrp_by_level(base, level)
end

function mdrd.print_result(force, result)
  force.print(string.format("mdrd: success %d, fail %d, noop %d", result.success, result.fail, result.noop))
end

function mdrd.upgrade_force(force, level)
  local result = {
    success = 0,
    fail = 0,
    noop = 0,
  }

  for _, surface in pairs(game.surfaces) do
    for _, mining_drill in ipairs(surface.find_entities_filtered { type = "mining-drill", force = force }) do
      local x = mdrd.upgrade(mining_drill, level)
      if x == mdrd.UPGRADE_NOOP then
        result.noop = result.noop + 1
      elseif x == mdrd.UPGRADE_SUCCESS then
        result.success = result.success + 1
      elseif x == mdrd.UPGRADE_FAIL then
        result.fail = result.fail + 1
      else
        log("mdrd: upgrade() return unexpected value")
      end
    end
  end

  return result
end

function mdrd.get_base_name(name)
  return string.match(name, "^(.*)%-mdrd.*$")
end

function mdrd.mining_name(base_name, quality_name, level)
  return base_name .. "-mdrd" .. quality_name .. level
end

function mdrd.is_normal_mining_drill(name)
  return not mdrd.get_base_name(name)
end

function mdrd.upgrade(mining_drill, level)
  local base_name = mdrd.get_base_name(mining_drill.name) or mining_drill.name
  local name
  if level then
    -- In case level is in unexpected state
    if level < 0 or level > mdrd.level_max then
      mining_drill.force.print("mdrd: cancel upgrade: level < 0 or level > level_max")
      return mdrd.UPGRADE_FAIL
    end
    name = mdrd.mining_name(base_name, mining_drill.quality.name, level)
  else
    name = base_name
  end

  if name == mining_drill.name or mdrd.ignore_list[base_name] then
    return mdrd.UPGRADE_NOOP
  elseif mining_drill.order_upgrade({
        target = {
          name = name,
          quality = mining_drill.quality
        },
        force = mining_drill.force,
      }) then
    mdrd.print_debug(mining_drill.force, string.format("mdrd: upgrade %s to %s", mining_drill.name, name))
    mining_drill.apply_upgrade()
    return mdrd.UPGRADE_SUCCESS
  else
    mining_drill.force.print(string.format("mdrd: can't upgrade %s to %s", mining_drill.name, name))
    return mdrd.UPGRADE_FAIL
  end
end

function mdrd.update_level(force)
  local level = 0
  for i = 1, mdrd.level_max do
    local tech = force.technologies["mining-efficiency-" .. i]
    if not tech.researched then
      break
    else
      level = i
    end
  end
  storage.forces[force.name] = level
end

function mdrd.upgrade_all()
  storage.forces = {}
  for name, force in pairs(game.forces) do
    mdrd.update_level(force)
    local result = mdrd.upgrade_force(force, storage.forces[name])
    mdrd.print_result(force, result)
  end
end

function mdrd.unresearch_all()
  storage.forces = {}
  for name, force in pairs(game.forces) do
    for i = 1, mdrd.level_max do
      local tech = force.technologies["mining-efficiency-" .. i]
      tech.researched = false
    end
    storage.forces[name] = nil
    local result = mdrd.upgrade_force(force, nil)
    mdrd.print_result(force, result)
  end
end

function mdrd.info(command)
  local player = game.get_player(command.player_index)
  if player then
    local level = storage.forces[player.force.name] or 0
    player.print({"mdrd.symbol", tostring(level)})
    player.print({"mdrd.efficiency", string.format("%d", mdrd.mining_effectiveness_by_level(100, level))})
  end
end

function mdrd.downgrade_all()
  storage.forces = {}
  for name, force in pairs(game.forces) do
    storage.forces[name] = nil
    local result = mdrd.upgrade_force(force, nil)
    mdrd.print_result(force, result)
  end
end

return mdrd