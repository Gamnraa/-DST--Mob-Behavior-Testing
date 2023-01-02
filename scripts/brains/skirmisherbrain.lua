require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/panic"

local MAX_CHASE_DIST = 50
local SEE_PLAYER_DIST = 8
local STOP_RUN_AWAY_DIST = 12

local SkirmisherBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SkirmisherBrain:OnStart()
    local root = 
        PriorityNode(
        {
            WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
            WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
            EventNode(self.inst, "attacked", RunAway(self.inst, "scarytoprey", SEE_PLAYER_DIST, STOP_RUN_AWAY_DIST + 4)),
            SequenceNode{
                ChaseAndAttack(self.inst, MAX_CHASE_DIST),
                RunAway(self.inst, "scarytoprey", SEE_PLAYER_DIST, STOP_RUN_AWAY_DIST),
            },
            Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, 32)
        }, 1)
    self.bt = BT(self.inst, root)
end

function SkirmisherBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()))
end

return SkirmisherBrain