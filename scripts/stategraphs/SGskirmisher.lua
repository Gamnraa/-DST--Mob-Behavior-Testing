require("stategraphs/commonstates")																
--I don't need every line to explained to me like I'm 5 years old
local events = {																				
	EventHandler("attacked", function(inst)														
        if not inst.components.health:IsDead() then												
			inst.sg:GoToState("hit")															
        end
    end),
	
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),						
	EventHandler("doattack", function(inst, data) 
        if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack", data.target) end 
    end),

    CommonHandlers.OnFreeze(),
    CommonHandlers.OnLocomote(true, false),														
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
    },	
    
    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,

        timeline =
        {

            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
            TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) if math.random() < .333 then inst.components.combat:SetTarget(nil) inst.sg:GoToState("taunt") else inst.sg:GoToState("idle", "atk_pst") end end),
        },
    },																			

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
CommonStates.AddAmphibiousCreatureHopStates(states,
{ -- config
	swimming_clear_collision_frame = 9 * FRAMES,
},
{ -- anims
},
{ -- timeline
	hop_pre =
	{
		TimeEvent(0, function(inst)
			if inst:HasTag("swimming") then
				SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
			end
		end),
	},
	hop_pst = {
		TimeEvent(4 * FRAMES, function(inst)
			if inst:HasTag("swimming") then
				inst.components.locomotor:Stop()
				SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
			end
		end),
		TimeEvent(6 * FRAMES, function(inst)
			if not inst:HasTag("swimming") then
                inst.components.locomotor:StopMoving()
			end
		end),
	}
})

CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        TimeEvent(30 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end),
    },
})
CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.growl)
            if inst:HasTag("swimming") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
            else
                if inst:HasTag("clay") then
                    PlayClayFootstep(inst)
                else
                    PlayFootstep(inst)
                end
            end
        end),
        TimeEvent(4 * FRAMES, function(inst)
            if inst:HasTag("swimming") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
            else
                if inst:HasTag("clay") then
                    PlayClayFootstep(inst)
                else
                    PlayFootstep(inst)
                end
            end
        end),
    },
})

CommonStates.AddFrozenStates(states)															-- Add frozes states to the given table of states

return StateGraph("SGskirmisher", states, events, "idle")									