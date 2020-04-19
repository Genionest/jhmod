local assets ={
	Asset("ANIM", "anim/buling_food.zip"),
	Asset("ATLAS", "images/inventoryimages/buling_cooktable.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_aoliao.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_baojiangdangao.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_bingkaxianbing.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_flour.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_hongguzhou.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_jianbingguozi.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_jiangguomusi.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_kaodigua.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_kaolengmian.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_languzhou.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_luobubao.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_lvguzhou.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_mapodoufu.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_qiancengbing.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_sangubao.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_sanmingzhi.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_suroudacan.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_tianmishala.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_xiangcaobuding.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_xiangjiaoxianbing.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_xiguazhi.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_bread.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_cook_guo.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_cook_kao.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_cook_zheng.xml"),
	Asset("ATLAS", "images/inventoryimages/buling_xifan.xml"),
}
local cookhechengbiao ={
	["buling_cook_kao"]={"cutstone,nil,cutstone,cutstone,cutstone,cutstone,charcoal,torch,charcoal,"},
	["buling_cook_guo"]={"nil,nil,nil,buling_zhongziding,nil,buling_zhongziding,buling_zhongziding,buling_zhongziding,buling_zhongziding,"},
	["buling_cook_zheng"]={"boards,boards,boards,nil,nil,nil,boards,boards,boards,"},
	["buling_bread"]={"nil,nil,nil,nil,buling_flour,nil,nil,buling_cook_kao,nil,"},
	["buling_xifan"]={"nil,nil,nil,nil,buling_flour,nil,nil,buling_cook_guo,nil,"},
	["buling_baojiangdangao"]={"nil,berries_cooked,nil,buling_bread,honey,buling_bread,nil,buling_cook_kao,nil,"},
	["buling_jianbingguozi"]={"bird_egg,plantmeat,bird_egg,buling_flour,buling_flour,buling_flour,nil,buling_cook_kao,nil,"},
	["buling_kaodigua"]={"nil,nil,nil,nil,sweet_potato,nil,nil,buling_cook_kao,nil,"},
	["buling_bingkaxianbing"]={"nil,ratatouille,nil,buling_flour,buling_flour,buling_flour,nil,buling_cook_kao,nil,"},
	["buling_kaolengmian"]={"nil,bird_egg,nil,nil,buling_flour,nil,nil,buling_cook_kao,nil,"},
	["buling_sanmingzhi"]={"nil,buling_bread,nil,cactus_meat,flowersalad,cactus_meat,nil,buling_bread,nil,"},
	["buling_qiancengbing"]={"buling_flour,buling_flour,buling_flour,plantmeat,honey,plantmeat,buling_flour,buling_cook_kao,buling_flour,"},
	["buling_xiangcaobuding"]={"tallbirdegg,petals,goatmilk,buling_flour,honey,buling_flour,nil,buling_cook_zheng,nil,"},
	["buling_jiangguomusi"]={"nil,berries,nil,coconut_cooked,nil,coconut_cooked,nil,nil,nil,"},
	["buling_luobubao"]={"carrot,carrot,carrot,nil,buling_xifan,nil,nil,buling_cook_guo,nil,"},
	["buling_aoliao"]={"buling_flour,coffeebeans_cooked,buling_flour,buling_flour,coffeebeans_cooked,buling_flour,nil,buling_cook_kao,nil,"},
	["buling_sangubao"]={"red_cap,green_cap,blue_cap,nil,buling_xifan,nil,nil,buling_cook_zheng,nil,"},
	["buling_lvguzhou"]={"nil,green_cap,nil,nil,buling_xifan,nil,nil,buling_cook_guo,nil,"},
	["buling_languzhou"]={"nil,blue_cap,nil,nil,buling_xifan,nil,nil,buling_cook_guo,nil,"},
	["buling_hongguzhou"]={"nil,red_cap,nil,nil,buling_xifan,nil,nil,buling_cook_guo,nil,"},
}
local seg_time = 30
local total_day_time = seg_time*16
local slotpos = {}
for y = 2, 0, -1 do
	for x = 0, 2 do
		table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
	end
end
local function cooktable(inst)
	local widgetbuttoninfo = {
	text = "Do",
	position = Vector3(0, -140, 0),
	fn = function(inst)
		local peifang = ""
		local slots = inst.components.container.slots
		for k=1,9 do
			local item = inst.components.container:GetItemInSlot(k)
			if item == nil then
				item = "nil"
				else
				item = item.prefab
			end
			peifang = peifang..item..","
		end
		for k,v in pairs(cookhechengbiao) do
			if v[1] == peifang then
				local item = inst.components.container:GetItemInSlot(8)
				if item and item:HasTag("buling_cook_tool") then
					item = inst.components.container:GetItemInSlot(8).prefab
				else
					item = nil
				end
				inst.components.container:DestroyContents()
				inst.components.container:GiveItem(SpawnPrefab(k), 5)
				if item then
					inst.components.container:GiveItem(SpawnPrefab(item), 8)
				end
			end
		end
	end}
	local function OnOpen(inst)
		GetPlayer():PushEvent("OpenBuling_food")
	end
	local function OnClose(inst)
		GetPlayer():PushEvent("CloseBuling_food")
	end
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
	inst.AnimState:SetBank("buling_box")
    inst.AnimState:SetBuild("buling_box")
	inst.AnimState:PlayAnimation("cooktable")
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slotpos)
	inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 100
	inst.components.container.widgetbuttoninfo = widgetbuttoninfo
	inst.components.container.acceptsstacks = false
	inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
	inst.beeritem = "buling_cooktable_item"
	return inst
end
---通用
local function commonfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	inst:AddComponent("edible")
	inst.bl_hea = 0
	inst.bl_hun = 0
	inst.bl_san = 0
	inst.bl_ady = 10
	inst.AnimState:SetBank("buling_food")
    inst.AnimState:SetBuild("buling_food")
	inst.components.edible.foodtype = "VEGGIE"
	inst:DoTaskInTime(0,function()
		inst.components.edible.healthvalue = inst.bl_hea
		inst.components.edible.hungervalue = inst.bl_hun
		inst.components.edible.sanityvalue = inst.bl_san
	end) 
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(inst.bl_ady*total_day_time)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    return inst
end
--食材
local function buling_food_mianfen(inst)--面粉
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_flour"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_flour.xml"
	inst.AnimState:PlayAnimation("flour")
	inst.bl_ady = 40
    return inst
end
local function buling_bread(inst)--面包
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_bread"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bread.xml"
	inst.AnimState:PlayAnimation("buling_bread")
	inst.bl_hea = 0
	inst.bl_hun = 10
	inst.bl_san = 0
    return inst
end
local function buling_xifan(inst)--稀饭
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_xifan"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_xifan.xml"
	inst.AnimState:PlayAnimation("buling_xifan")
	inst.bl_hea = 0
	inst.bl_hun = 10
	inst.bl_san = 0
    return inst
end
--料理
local function buling_food_aoliao(inst)--奥利奥
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_aoliao"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_aoliao.xml"
	inst.AnimState:PlayAnimation("aoliao")
	inst.bl_hea = 10
	inst.bl_hun = 10
	inst.bl_san = -10
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.locomotor then
			eater.components.locomotor:AddSpeedModifier_Additive("CAFFEINE",5, total_day_time/2)
		end
	end)
    return inst
end
local function buling_food_baojiangdangao(inst)--爆浆蛋糕
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_baojiangdangao"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_baojiangdangao.xml"
	inst.AnimState:PlayAnimation("buling_baojiangdangao")
	inst.bl_hea = 10
	inst.bl_hun = 50
	inst.bl_san = 10
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('buling_kaiwei', 250,0,50,0)
		end
	end)
    return inst
end
local function buling_bingkaxianbing(inst)--宾卡馅饼
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_bingkaxianbing"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_bingkaxianbing.xml"
	inst.AnimState:PlayAnimation("buling_bingkaxianbing")
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('buling_tishen', 200,0,0,50)
		end
	end)
	inst.bl_hea = 40
	inst.bl_hun = 20
	inst.bl_san = 15

    return inst
end
local function buling_sanmingzhi(inst)--三明治
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_sanmingzhi"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_sanmingzhi.xml"
	inst.AnimState:PlayAnimation("buling_sanmingzhi")
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('buling_chaotishen', 30,0,0,0)
		end
	end)
	inst.bl_hea = 0
	inst.bl_hun = 30
	inst.bl_san = 0

    return inst
end
local function buling_kaolengmian(inst)--烤冷面
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_kaolengmian"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_kaolengmian.xml"
	inst.AnimState:PlayAnimation("buling_kaolengmian")
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('buling_kaiwei', 30,0,50,0)
		end
	end)
	inst.bl_hea = 5
	inst.bl_hun = 30
	inst.bl_san = 5

    return inst
end
local function buling_hongguzhou(inst)--红菇煲
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_hongguzhou"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_hongguzhou.xml"
	inst.AnimState:PlayAnimation("buling_hongguzhou")
	inst.bl_hea = 1
	inst.bl_hun = 20
	inst.bl_san = 5
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.poisonable:Cure(eater)
		end
	end)
    return inst
end
local function buling_jianbingguozi(inst)--煎饼果子
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_jianbingguozi"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_jianbingguozi.xml"
	inst.AnimState:PlayAnimation("buling_jianbingguozi")
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('buling_jiankang', 180,50,0,0)
		end
	end)
	inst.bl_hea = 50
	inst.bl_hun = 10
	inst.bl_san = 20

    return inst
end
local function buling_jiangguomusi(inst)--浆果慕斯
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_jiangguomusi"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_jiangguomusi.xml"
	inst.AnimState:PlayAnimation("buling_jiangguomusi")
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('buling_meiwei', 30,0,0,0)
		end
	end)
	inst.bl_hea = 5
	inst.bl_hun = 20
	inst.bl_san = 15

    return inst
end
local function buling_languzhou(inst)--蓝菇煲
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_languzhou"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_languzhou.xml"
	inst.AnimState:PlayAnimation("buling_languzhou")
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('buling_yangsheng', 60,0,0,0)
		end
	end)
	inst.bl_hea = 10
	inst.bl_hun = 15
	inst.bl_san = 5

    return inst
end
local function buling_luobubao(inst)--萝卜煲
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_luobubao"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_luobubao.xml"
	inst.AnimState:PlayAnimation("buling_luobubao")
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('buling_yeshi', 60,0,0,0)
		end
	end)
	inst.Transform:SetScale(2, 2,2)
	inst.bl_hea = 5
	inst.bl_hun = 40
	inst.bl_san = 5

    return inst
end
local function buling_lvguzhou(inst)--绿菇煲
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_lvguzhou"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_lvguzhou.xml"
	inst.AnimState:PlayAnimation("buling_lvguzhou")
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('buling_meiwei', 60,0,0,0)
		end
	end)
	inst.bl_hea = 1
	inst.bl_hun = 15
	inst.bl_san = 20

    return inst
end
local function buling_mapodoufu(inst)--麻婆豆腐
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_mapodoufu"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_mapodoufu.xml"
	inst.AnimState:PlayAnimation("buling_mapodoufu")
	inst.bl_hea = 50
	inst.bl_hun = 10
	inst.bl_san = 20

    return inst
end
local function buling_sangubao(inst)--三菇煲
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_sangubao"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_sangubao.xml"
	inst.AnimState:PlayAnimation("buling_sangubao")
	inst.bl_hea = 50
	inst.bl_hun = 50
	inst.bl_san = 50
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('fulanke', 120,50,50,50)
		end
	end)
    return inst
end
local function buling_qiancengbing(inst)--千层饼
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_qiancengbing"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_qiancengbing.xml"
	inst.AnimState:PlayAnimation("buling_qiancengbing")
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('buling_chaobaofu', 30,0,0,0)
		end
	end)
	inst.bl_hea = 50
	inst.bl_hun = 20
	inst.bl_san = 20

    return inst
end
local function buling_xiangcaobuding(inst)--香草布丁
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_xiangcaobuding"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_xiangcaobuding.xml"
	inst.AnimState:PlayAnimation("buling_xiangcaobuding")
	inst.components.edible:SetOnEatenFn(function(inst,eater)
		if eater.components.buling_buff then
			eater.components.buling_buff:Addbulingbuff_Additive('buling_chaomeiwei', 30,0,0,0)
		end
	end)
	inst.bl_hea = 50
	inst.bl_hun = 10
	inst.bl_san = 20

    return inst
end
local function buling_tianmishala(inst)--甜蜜沙拉
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_tianmishala"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_tianmishala.xml"
	inst.AnimState:PlayAnimation("buling_tianmishala")
	inst.bl_hea = 50
	inst.bl_hun = 10
	inst.bl_san = 20

    return inst
end
local function buling_xiangjiaoxianbing(inst)--香蕉煎饼
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_xiangjiaoxianbing"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_xiangjiaoxianbing.xml"
	inst.AnimState:PlayAnimation("buling_xiangjiaoxianbing")
	inst.bl_hea = 50
	inst.bl_hun = 10
	inst.bl_san = 20

    return inst
end
local function buling_xiguazhi(inst)--西瓜汁
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_xiguazhi"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_xiguazhi.xml"
	inst.AnimState:PlayAnimation("buling_xiguazhi")
	inst.bl_hea = 50
	inst.bl_hun = 10
	inst.bl_san = 20

    return inst
end
local function buling_suroudacan(inst)--素肉大餐
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_suroudacan"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_suroudacan.xml"
	inst.AnimState:PlayAnimation("buling_suroudacan")
	inst.bl_hea = 50
	inst.bl_hun = 10
	inst.bl_san = 20

    return inst
end
local function buling_kaodigua(inst)--炸地瓜
    local inst = commonfn(inst)
	inst.components.inventoryitem.imagename = "buling_kaodigua"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/buling_kaodigua.xml"
	inst.AnimState:PlayAnimation("buling_kaodigua")
	inst.bl_hea = 0
	inst.bl_hun = 30
	inst.bl_san = 5

    return inst
end
return Prefab("buling_cooktable", cooktable, assets),--料理台
Prefab("buling_flour", buling_food_mianfen, assets),--面粉
Prefab("buling_baojiangdangao", buling_food_baojiangdangao, assets),
Prefab("buling_sanmingzhi", buling_sanmingzhi, assets),
Prefab("buling_bread", buling_bread, assets),
Prefab("buling_xifan", buling_xifan, assets),
Prefab("buling_aoliao", buling_food_aoliao, assets),
Prefab("buling_bingkaxianbing", buling_bingkaxianbing, assets),
Prefab("buling_kaolengmian", buling_kaolengmian, assets),
Prefab("buling_hongguzhou", buling_hongguzhou, assets),
Prefab("buling_jianbingguozi", buling_jianbingguozi, assets),
Prefab("buling_jiangguomusi", buling_jiangguomusi, assets),
Prefab("buling_languzhou", buling_languzhou, assets),
Prefab("buling_luobubao", buling_luobubao, assets),
Prefab("buling_lvguzhou", buling_lvguzhou, assets),
Prefab("buling_mapodoufu", buling_mapodoufu, assets),
Prefab("buling_sangubao", buling_sangubao, assets),
Prefab("buling_qiancengbing", buling_qiancengbing, assets),
Prefab("buling_xiangcaobuding", buling_xiangcaobuding, assets),
Prefab("buling_tianmishala", buling_tianmishala, assets),
Prefab("buling_xiangjiaoxianbing", buling_xiangjiaoxianbing, assets),
Prefab("buling_xiguazhi", buling_xiguazhi, assets),
Prefab("buling_suroudacan", buling_suroudacan, assets),
Prefab("buling_kaodigua", buling_kaodigua, assets),
MakePlacer("buling_cooktable_placer", "buling_box", "buling_box", "cooktable")