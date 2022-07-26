local SphereHitbox = require(script.SphereHitbox)
local PartHitbox = require(script.PartHitbox)
local BoxHitbox = require(script.BoxHitbox)

--[=[
    @class SimpleHitbox
]=]
local SimpleHitbox = {}

local Debug = false

--[=[
    Create a new sphere hitbox.

    @param inst Instance? -- Instance the hitbox should follow

    ::caution
        Providing an Instance will only set the sphere hitbox's position. You must manually set the radius.
    ::
]=]
function SimpleHitbox.NewSphereHitbox(inst: Instance?)
    if Debug then
        SphereHitbox.Debug = true
    end
    return SphereHitbox.new(inst)
end

--[=[
    Create a new part hitbox.

    @param inst Instance -- Part for the hitbox or instance containing parts for the hitbox
]=]
function SimpleHitbox.NewPartHitbox(inst: Instance)
    if Debug then
        PartHitbox.Debug = true
    end
    return PartHitbox.new(inst)
end

--[=[
    Create a new box hitbox.

    @param inst Instance? -- Instance the hitbox should follow. The hitbox' size will also be taken from the instance if it has a size.
]=]
function SimpleHitbox.NewBoxHitbox(inst: Instance?)
    if Debug then
        BoxHitbox.Debug = true
    end
    return BoxHitbox.new(inst)
end

return SimpleHitbox

