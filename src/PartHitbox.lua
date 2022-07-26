local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Signal = require(script.Parent.Parent.Signal)

--[=[
	@class PartHitbox

	A hitbox that uses Roblox's :GetPartsInPart()
]=]
local PartHitbox = {
    Debug = false,
}
PartHitbox.__index = PartHitbox

--[=[
	@within PartHitbox
	@prop OverlapParams OverlapParams

	The overlap parameters for the hitbox.
]=]

--[=[
	@within PartHitbox
	@prop OnHit Signal

	Fired when the hitbox gets a hit on a player.

	```lua
	local partHitbox = SimpleHitbox.NewPartHitbox(part)
	partHitbox.OverlapParams = OverlapParams.new()
	partHitbox:HitStart()

	partHitbox.OnHit:Connect(function(hit, humanoid)
		print("Hit!")
	end)
	```
]=]

function PartHitbox.new(inst: Instance)
	if not inst then
		error("Must give an instance!")
		return nil
	end
	local self = setmetatable({
		_instance = inst,
		_listenStart = 0,
		_listening = false,
		_heartbeatConnection = nil,
		OnHit = Signal.new(),
		OverlapParams = nil,
	}, PartHitbox)

    if self.Debug then
        self._debugInst = inst:Clone()
        if self._debugInst:IsA("BasePart") then
            self._debugInst.Transparency = 1
            self._debugInst.Material = Enum.Material.Neon
            self._debugInst.Anchored = false
			self._debugInst.CastShadow = false
            self._debugInst.CanCollide = false
            self._debugInst.BrickColor = BrickColor.Red()

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = self._debugInst
            weld.Part1 = inst
            weld.Parent = self._debugInst
		else
			for _, p in ipairs(self._debugInst:GetDescendants()) do
				if not p:IsA("BasePart") then
					p:Destroy()
					continue
				end

				p.Transparency = 1
				p.Material = Enum.Material.Neon
				p.Anchored = false
				p.CastShadow = false
				p.CanCollide = false
				p.BrickColor = BrickColor.Red()

				local weld = Instance.new("WeldConstraint")
				weld.Part0 = p
				weld.Part1 = inst:FindFirstChildOfClass("BasePart") -- meh
				weld.Parent = p
			end
        end
        self._debugInst.Parent = workspace
    end

    return self
end

--[=[
	Start listening for hits.

	@param maxTime number? -- Maximum time the hitbox can stay on for. Once this runs out, the hitbox will automatically stop listening for hits.

	:::caution WARNING
	The overlap parameters must be specified before calling this function!
	:::
]=]
function PartHitbox:HitStart(maxTime: number?)
	self._listenStart = os.clock()
	self._listening = true
    if self.Debug and self._debugInst then
        if self._debugInst:IsA("BasePart") then
            self._debugInst.Transparency = 0.5
        end
    end
	self._heartbeatConnection = RunService.Heartbeat:Connect(function()
		if maxTime and os.clock() - self._listenStart >= maxTime then
			self:HitStop()
			return
		end

		if self.OverlapParams then
			if self._instance then
				if self._instance:IsA("BasePart") then
					local hits = Workspace:GetPartsInPart(self._instance, self.OverlapParams)
					if #hits > 0 then
						for _, hit in ipairs(hits) do
							if hit:IsA("BasePart") then
								local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
								if hum then
									self.OnHit:Fire(hit, hum)
								end
							end
						end
					end
				else
					for _, part in ipairs(self._instance:GetChildren()) do
						if not part:IsA("BasePart") then
							continue
						end
						local hits = Workspace:GetPartsInPart(part, self.OverlapParams)
						if #hits > 0 then
							for _, hit in ipairs(hits) do
								if hit:IsA("BasePart") then
									local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
									if hum then
										self.OnHit:Fire(hit, hum)
									end
								end
							end
						end
					end
				end
			else
				warn("No instance was given!")
			end
		else
			warn("No OverlapParams were specified!")
		end
	end)
end

--[=[
	Stop listening for hits.
]=]
function PartHitbox:HitStop()
	if self._listening then
		self._heartbeatConnection:Disconnect()
		self._listening = false
        if self.Debug and self._debugInst then
            if self._debugInst:IsA("BasePart") then
                self._debugInst.Transparency = 1
            end
        end
	end
end

--[=[
	Destroy the hitbox. This automatically calls HitStop and destroys the signal.

	:::caution WARNING
	The hitbox will be unusable once this is called!
	:::
]=]
function PartHitbox:Destroy()
    if self.Debug and self._debugInst then
        self._debugInst:Destroy()
    end
end

return PartHitbox
