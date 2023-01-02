local assets =
{
    Asset("ANIM", "anim/hound_basic.zip"),
    Asset("ANIM", "anim/hound_basic_water.zip"),
    Asset("ANIM", "anim/hound.zip"),
    Asset("ANIM", "anim/hound_ocean.zip"),
    Asset("SOUND", "sound/hound.fsb"),
}

local prefabs =
{
    "houndstooth",
    "monstermeat",
}

local brain = require("brains/skirmisherbrain")

local sounds =
{
    pant = "dontstarve/creatures/hound/pant",
    attack = "dontstarve/creatures/hound/attack",
    bite = "dontstarve/creatures/hound/bite",
    bark = "dontstarve/creatures/hound/bark",
    death = "dontstarve/creatures/hound/death",
    sleep = "dontstarve/creatures/hound/sleep",
    growl = "dontstarve/creatures/hound/growl",
    howl = "dontstarve/creatures/together/clayhound/howl",
    hurt = "dontstarve/creatures/hound/hurt",
}

SetSharedLootTable('hound_skirmisher',
{
    {'monstermeat', 1.000},
    {'houndstooth', 0.125},
})

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, 0.5)

    inst.DynamicShadow:SetSize(1.5, 0.5)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("hound")
    inst.AnimState:SetBuild("hound_ocean")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end 

    inst.sounds =
    {
        pant = "dontstarve/creatures/hound/pant",
        attack = "dontstarve/creatures/hound/attack",
        bite = "dontstarve/creatures/hound/bite",
        bark = "dontstarve/creatures/hound/bark",
        death = "dontstarve/creatures/hound/death",
        sleep = "dontstarve/creatures/hound/sleep",
        growl = "dontstarve/creatures/hound/growl",
        howl = "dontstarve/creatures/together/clayhound/howl",
        hurt = "dontstarve/creatures/hound/hurt",
    }

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 6
    inst.components.locomotor.runspeed = 7

    inst:SetStateGraph("SGskirmisher")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("hound_skirmisher")

    MakeMediumBurnableCharacter(inst, "hound_body")
    MakeMediumFreezableCharacter(inst, "hound_body")
    inst.components.burnable.fammability = 0.33 --typo??

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(100)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")

    MakeHauntablePanic(inst)

    inst:SetBrain(brain)

    return inst
end

return Prefab("hound_skirmisher", fn, assets, prefabs)

