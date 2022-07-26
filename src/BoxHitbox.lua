local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Signal = require(script.Parent.Parent.Signal)

--[=[
	@class BoxHitbox

	A hitbox that uses Roblox's :GetPartBoundsInBox()
]=]
local BoxHitbox = {
    Debug = false,
}
BoxHitbox.__index = BoxHitbox

--[=[
	@within BoxHitbox
	@prop OverlapParams OverlapParams

	The overlap parameters for the hitbox.
]=]

--[=[
	@within BoxHitbox
	@prop CFrame CFrame

	The CFrame of the hitbox.

	:::caution WARNING
	Setting the CFrame won't update the hitbox if you have provided an instance for it to follow!
	:::

	```lua
	local boxHitbox = SimpleHitbox.NewBoxHitbox()

	boxHitbox.CFrame = CFrame.new(0, 5, 0)
	```
]=]

--[=[
	@within BoxHitbox
	@prop Size Vector3

	The size of the hitbox.

	:::caution WARNING
	Setting the size won't update the hitbox if you have provided an instance for it to follow!
	:::

	```lua
	local boxHitbox = SimpleHitbox.NewBoxHitbox()

	boxHitbox.Size = 5
	```
]=]

--[=[
	@within BoxHitbox
	@prop OnHit Signal

	Fired when the hitbox gets a hit on a player.

	```lua
	local boxHitbox = SimpleHitbox.NewBoxHitbox()
	boxHitbox.OverlapParams = OverlapParams.new()
	boxHitbox:HitStart()

	boxHitbox.OnHit:Connect(function(hit, humanoid)
		print("Hit!")
	end)
	```
]=]
--[=[
	Destroy the hitbox. This automatically calls HitStop and destroys the signal.

	:::caution WARNING
	The hitbox will be unusable once this is called!
	:::
]=]

function BoxHitbox.new(inst: Instance?)
	local self = setmetatable({
		_instance = inst,
		OverlapParams = nil,
		CFrame = CFrame.new(),
		Size = Vector3.new(),
		OnHit = Signal.new(),
		_heartbeatConnection = nil,
		_listening = false,
		_listenStart = 0,
	}, BoxHitbox)

    if self.Debug then
        local debugInst = Instance.new("Part")
        debugInst.Size = self.Size
        debugInst.CFrame = self.CFrame
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
	The CFrame, size and overlap parameters must be specified before calling this function!
	:::
]=]
function BoxHitbox:HitStart(maxTime: number?)
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
                if self._instance.CFrame then
				    self.CFrame = self._instance.CFrame
                elseif self._instance.Position then
                    self.CFrame = CFrame.new(self._instance.Position)
                end
				if self._instance.Size then
					self.Size = self._instance.Size
				end
			end
            if self.Debug and self._debugInst then
                self._debugInst.CFrame = self.CFrame
                self._debugInst.Size = self.Size
            end
			if self.CFrame and self.Size then
				local hits = Workspace:GetPartBoundsInBox(self.CFrame, self.Size, self.OverlapParams)
				if #hits > 0 then
					for _, hit in ipairs(hits) do
						if hit:IsA("BasePart") and hit.Parent:FindFirstChildOfClass("Humanoid") then
							self.OnHit:Fire(hit, hit.Parent:FindFirstChildOfClass("Humanoid"))
							didHit = true
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
				warn("No position or size was set!")
			end
		else
			warn("No OverlapParams were specified!")
		end
	end)
end

--[=[
	Stop listening for hits.
]=]
function BoxHitbox:HitStop()
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
function BoxHitbox:Destroy()
    if self.Debug and self._debugInst then
        self._debugInst:Destroy()
    end
end

return BoxHitbox
