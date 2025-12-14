local mdrd = require("mdrd")

local filter_mining_drill = { filter = "type", type = "mining-drill" }

script.on_init(function()
  storage.forces = {}
end)

script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.entity
  local level = storage.forces[entity.force.name]
  mdrd.upgrade(entity, level)
end, {filter_mining_drill})

script.on_event(defines.events.on_robot_built_entity, function(event)
  local entity = event.entity
  local level = storage.forces[entity.force.name]
  mdrd.upgrade(entity, level)
end, {filter_mining_drill})

script.on_event(defines.events.on_technology_effects_reset, function (event)
  local force = event.force
  local result = mdrd.upgrade_force(force, storage.forces[force.name])
  if mdrd.debug then
    mdrd.print_result(force, result)
  end
end)

script.on_event(defines.events.on_research_finished, function(event)
  local research = event.research
  local name, level = string.match(research.name, "^(.-)%-(%d+)$")
  if name == "mining-efficiency" then
    level = tonumber(level)
    local force = research.force
    storage.forces[force.name] = level
    local result = mdrd.upgrade_force(force, level)
    if mdrd.debug then
      mdrd.print_result(force, result)
    end
  end
end)

commands.add_command(
  "mdrd_info",
  "Show current efficiency of drills",
  mdrd.info
)

commands.add_command(
  "mdrd_upgrade_all",
  "Opposite of mdrd_downgrade_all will put back mdrd mining drill entities",
  mdrd.upgrade_all
)

commands.add_command(
  "mdrd_downgrade_all",
  "Opposite of mdrd_upgrade_all will put back all mdrd drills to normal drills",
  mdrd.downgrade_all
)

commands.add_command(
  "mdrd_unresearch_all",
  "Unresearch Mining Efficiency tech",
  mdrd.unresearch_all
)
