local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Signal = require(script.Parent.Parent.Signal)

--[=[
	@class SphereHitbox

	A hitbox that uses Roblox's :GetPartBoundsInRadius()
]=]
local SphereHitbox = {
    Debug = false,
}
SphereHitbox.__index = SphereHitbox

--[=[
	@within SphereHitbox
	@prop OverlapParams OverlapParams

	The overlap parameters for the hitbox.
]=]

--[=[
	@within SphereHitbox
	@prop Position Vector3

	The position of the hitbox.

	:::caution WARNING
	Setting this position won't update the hitbox if you have provided an instance for it to follow!
	:::

	```lua
	local sphereHitbox = SimpleHitbox.NewSphereHitbox()

	sphereHitbox.Position = Vector3.new(0, 5, 0)
	```
]=]

--[=[
	@within SphereHitbox
	@prop Radius number

	The radius of the hitbox.

	```lua
	local sphereHitbox = SimpleHitbox.NewSphereHitbox()

	sphereHitbox.Radius = 5
	```
]=]

--[=[
	@within SphereHitbox
	@prop OnHit Signal

	Fired when the hitbox gets a hit on a player.

	```lua
	local sphereHitbox = SimpleHitbox.NewSphereHitbox()
	sphereHitbox.OverlapParams = OverlapParams.new()
	sphereHitbox:HitStart()

	sphereHitbox.OnHit:Connect(function(hit, humanoid)
		print("Hit!")
	end)
	```
]=]

function SphereHitbox.new(inst: Instance?)
	local self = setmetatable({
		_instance = inst,
		OverlapParams = nil,
		Position = Vector3.new(),
		Radius = 0,
		OnHit = Signal.new(),
		_heartbeatConnection = nil,
		_listening = false,
		_listenStart = 0,
	}, SphereHitbox)

    if self.Debug then
        local debugInst = Instance.new("Part")
        debugInst.Shape = Enum.PartType.Ball
        debugInst.Size = Vector3.new(self.Radius * 2, self.Radius * 2, self.Radius * 2)
        debugInst.Position = self.Position
        debugInst.CanCollide = false
		debugInst.CastShadow = false
        debugInst.Anchored = true
        debugInst.BrickColor = BrickColor.Red()
        debugInst.Transparency = 1
        debugInst.Material = Enum.Material.Neon
        debugInst.Parent = workspace
        self._debugInst = debugInst
    end

    return self
end

--[=[
	Start listening for hits.

	@param maxTime number? -- Maximum time the hitbox can stay on for. Once this runs out, the hitbox will automatically stop listening for hits.

	:::caution WARNING
	The position, radius and overlap parameters must be specified before calling this function!
	:::
]=]
function SphereHitbox:HitStart(maxTime: number?)
	self._listenStart = os.clock()
	self._listening = true
	if self.Debug and self._debugInst then
		self._debugInst.Transparency = 0.5
	end
	self._heartbeatConnection = RunService.Heartbeat:Connect(function()
		if maxTime and os.clock() - self._listenStart >= maxTime then
			self:HitStop()
			return
		end

		local didHit = false

		if self.OverlapParams then
			if self._instance then
				self.Position = self._instance.Position
			end
			if self.Debug and self._debugInst then
				self._debugInst.Position = self.Position
				self._debugInst.Size = Vector3.new(self.Radius * 2, self.Radius * 2, self.Radius * 2)
			end
			if self.Position and self.Radius then
				local hits = Workspace:GetPartBoundsInRadius(self.Position, self.Radius, self.OverlapParams)
				if #hits > 0 then
					for _, hit in ipairs(hits) do
						if hit:IsA("BasePart") and hit.Parent:FindFirstChildOfClass("Humanoid") then
							self.OnHit:Fire(hit, hit.Parent:FindFirstChildOfClass("Humanoid"))
							if self.Debug then
								didHit = true
							end
						end
					end
				end
				if self.Debug and self._debugInst then
					if didHit then
						self._debugInst.BrickColor = BrickColor.Green()
					else
						self._debugInst.BrickColor = BrickColor.Red()
					end
				end
			else
				warn("No position or radius was set!")
			end
		else
			warn("No OverlapParams were specified!")
		end
	end)
end

--[=[
	Stop listening for hits.
]=]
function SphereHitbox:HitStop()
	if self._listening then
		self._heartbeatConnection:Disconnect()
		self._listening = false
		if self.Debug and self._debugInst then
			self._debugInst.Transparency = 1
		end
	end
end

--[=[
	Destroy the hitbox. This automatically calls HitStop and destroys the signal.

	:::caution WARNING
	The hitbox will be unusable once this is called!
	:::
]=]
function SphereHitbox:Destroy()
	self:HitStop()
	self.OnHit:Destroy()
	setmetatable(self, nil)
    if self.Debug and self._debugInst then
        self._debugInst:Destroy()
    end
end

return SphereHitbox
