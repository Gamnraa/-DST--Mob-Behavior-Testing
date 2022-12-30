require "behaviours/wander"

local SkirmisherBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SkirmisherBrain:OnStart()
    local root = 
        PriorityNode(
        {
            Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, 32)
        }, 1)
    self.bt = BT(self.inst, root)
end

function SkirmisherBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()))
end

return SkirmisherBrain