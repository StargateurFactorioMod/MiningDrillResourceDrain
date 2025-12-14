local mdrd = require("mdrd")

for name, _ in pairs(storage.forces) do
  storage.forces[name] = tonumber(storage.forces[name])
end

mdrd.upgrade_all()