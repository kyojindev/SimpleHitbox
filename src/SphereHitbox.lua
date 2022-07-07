local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Signal = require(script.Parent.Parent.Signal)

local SphereHitbox = {
    Debug = false,
}
SphereHitbox.__index = SphereHitbox

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
				if self._instance.Size then
					self.Radius = self._instance.Size.Magnitude / 2
				end
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

function SphereHitbox:HitStop()
	if self._listening then
		self._heartbeatConnection:Disconnect()
		self._listening = false
		if self.Debug and self._debugInst then
			self._debugInst.Transparency = 1
		end
	end
end

function SphereHitbox:Destroy()
    if self.Debug and self._debugInst then
        self._debugInst:Destroy()
    end
end

return SphereHitbox
