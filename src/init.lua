local SphereHitbox = require(script.SphereHitbox)
local PartHitbox = require(script.PartHitbox)
local BoxHitbox = require(script.BoxHitbox)

local SimpleHitbox = {}

local Debug = false

function SimpleHitbox.NewSphereHitbox(inst: Instance?)
    if Debug then
        SphereHitbox.Debug = true
    end
    return SphereHitbox.new(inst)
end

function SimpleHitbox.NewPartHitbox(inst: Instance)
    if Debug then
        PartHitbox.Debug = true
    end
    return PartHitbox.new(inst)
end

function SimpleHitbox.NewBoxHitbox(inst: Instance?)
    if Debug then
        BoxHitbox.Debug = true
    end
    return BoxHitbox.new(inst)
end

return SimpleHitbox

