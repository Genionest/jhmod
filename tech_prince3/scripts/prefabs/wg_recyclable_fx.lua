return Prefab("wg_recyclable_fx", function()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst.persists = false
    return inst
end, {
    Asset("ANIM", "anim/the_fx01.zip"),
    Asset("ANIM", "anim/the_fx02.zip"),
    Asset("ANIM", "anim/the_fx03.zip"),
    Asset("ANIM", "anim/the_fx04.zip"),
    Asset("ANIM", "anim/the_fx05.zip"),
    Asset("ANIM", "anim/the_fx10.zip"),
    Asset("ANIM", "anim/the_fx12.zip"),
    Asset("ANIM", "anim/the_fx13.zip"),
    Asset("ANIM", "anim/the_fx14.zip"),
    Asset("ANIM", "anim/the_fx15.zip"),
    Asset("ANIM", "anim/the_fx16.zip"),
    Asset("ANIM", "anim/the_fx17.zip"),
    Asset("ANIM", "anim/the_fx18.zip"),
    Asset("ANIM", "anim/the_fx19.zip"),
    Asset("ANIM", "anim/the_fx21.zip"),
    Asset("ANIM", "anim/the_fx22.zip"),
    Asset("ANIM", "anim/the_fx23.zip"),
    Asset("ANIM", "anim/the_fx26.zip"),
    Asset("ANIM", "anim/the_fx27.zip"),
    Asset("ANIM", "anim/the_fx28.zip"),
    Asset("ANIM", "anim/the_fx29.zip"),
    Asset("ANIM", "anim/the_fx31.zip"),
    Asset("ANIM", "anim/the_fx33.zip"),
    Asset("ANIM", "anim/the_fx37.zip"),
    Asset("ANIM", "anim/the_fx39.zip"),
    Asset("ANIM", "anim/the_fx45.zip"),
    Asset("ANIM", "anim/the_fx47.zip"),
    Asset("ANIM", "anim/the_fx48.zip"),
    Asset("ANIM", "anim/the_fx50.zip"),
    Asset("ANIM", "anim/the_fx51.zip"),
    Asset("ANIM", "anim/the_fx60.zip"),
    Asset("ANIM", "anim/the_fxa11.zip"),
})