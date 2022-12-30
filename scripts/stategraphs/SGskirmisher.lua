require("stategraphs/commonstates")																
--I don't need every line to explained to me like I'm 5 years old
local events = {																				
	EventHandler("attacked", function(inst)														
        if not inst.components.health:IsDead() then												
			inst.sg:GoToState("hit")															
        end
    end),
	
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),						-- On death go to the 'death' state
	
    CommonHandlers.OnFreeze(),																	-- Common 'OnFreeze' state from commonstates.lua

    EventHandler("locomote", function(inst)														-- On movement
        if not inst.sg:HasStateTag("busy") then													-- If the current state doesn't have the 'busy' tag
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
			
            if is_moving ~= wants_to_move then													-- If is moving but doesn't want to OR is not moving but wants to move
                if wants_to_move then															-- If wants to move
                    inst.sg:GoToState("premoving")												-- Go to the 'premoving' state
                else																			-- If doesn't want to move
                    inst.sg:GoToState("idle")													-- Go to the 'idle' state
                end
            end
        end
    end),
}

local states = {																				-- The 'states' table for storing states
    State{																						-- \/ --		A STATE 		-- \/ --
        name = "death",																			-- The name of a state
        tags = {"busy"},																		-- The tags of the state

        onenter = function(inst)																-- On enter
            inst.AnimState:PlayAnimation("death")												-- Play the 'death' animation
            inst.Physics:Stop()																	-- Stop moving
            RemovePhysicsColliders(inst)														-- Stop colliding
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))	-- Drop loot
        end,
    },																							-- /\ --		A STATE			-- /\ --																						-- /\ --		A STATE			-- /\ --

    State{																						-- \/ --		A STATE 		-- \/ --
        name = "idle",																			-- The name of a state
        tags = {"idle", "canrotate"},															-- The tags of the state

        onenter = function(inst)																-- On enter
            inst.Physics:Stop()																	-- Stop moving
            inst.AnimState:PlayAnimation("idle", true)											-- Play the 'idle' animation, looped
        end,
    },																							-- /\ --		A STATE			-- /\ --

    State{																						-- \/ --		A STATE 		-- \/ --
        name = "hit",																			-- The name of a state
		tags = {"busy"},																		-- The tags of the state

        onenter = function(inst)																-- On enter
            inst.AnimState:PlayAnimation("hit")													-- Play the 'hit' animation
            inst.Physics:Stop()																	-- Stop moving
        end,

        events =																				-- Table of events for this state
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),				-- On 'animover', when the animation ends, go to the 'idle' state
        },
    }																							-- /\ --		A STATE			-- /\ --
}

CommonStates.AddFrozenStates(states)															-- Add frozes states to the given table of states

return StateGraph("SGskirmisher", states, events, "idle")									