# SimpleHitbox

A module made for creating simple hitboxes in Roblox.

# Todo

- Support for detecting more than players/npcs
- Support for more hitbox types
- Better debug support

# Example

```lua
local sphereHitbox = SimpleHitbox.NewSphereHitbox()
sphereHitbox.Position = Vector3.new(0, 15, 0)
sphereHitbox.Radius = 5

sphereHitbox.OnHit:Connect(function(hit, humanoid)
    print("Hit!")
end)

sphereHitbox:HitStart()

task.wait(10)

sphereHitbox:HitStop()
```