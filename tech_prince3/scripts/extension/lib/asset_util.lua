local AssetUtil = {}

local wg_img_cache = {}
local mod_img_list = {
	cutlichen = "algae",
    tp_coin = "oinc",
}
local wg_no_img_cache = {}

--[[
借鉴风铃大佬的函数，对图片资源的路径进行获取
]]
function AssetUtil:WindBellGetImg(atlas, img)
    local name = mod_img_list[atlas] or atlas
    img = img..".tex"
    if wg_img_cache[img] then
        return wg_img_cache[img].atlas,wg_img_cache[img].image
    end
    if TheSim:AtlasContains("images/inventoryimages.xml", img) then
        wg_img_cache[img] ={ atlas = "images/inventoryimages.xml",image=img}
        return "images/inventoryimages.xml",img
    elseif TheSim:AtlasContains("images/inventoryimages_2.xml", img) then
        wg_img_cache[img] ={ atlas =  "images/inventoryimages_2.xml",image=img}
        return "images/inventoryimages_2.xml",img
    else
        local trueatlas = softresolvefilepath("images/inventoryimages/"..name..".xml")
        if trueatlas and TheSim:AtlasContains(trueatlas, img) then
			wg_img_cache[img] = { atlas = "images/inventoryimages/"..name..".xml",image=img}
            return "images/inventoryimages/"..name..".xml",img
        end
        trueatlas = softresolvefilepath("images/"..name..".xml")
        if trueatlas and TheSim:AtlasContains(trueatlas, img) then
            wg_img_cache[img] ={ atlas =  "images/"..name..".xml",image=img}
            return "images/"..name..".xml",img
        end
        if PREFABDEFINITIONS[img] then
            for idx,asset in ipairs(PREFABDEFINITIONS[img].assets) do
              	if asset.type == "ATLAS" then
                	trueatlas = asset.file
              	end
            end
        end 
        if trueatlas and TheSim:AtlasContains(softresolvefilepath(trueatlas), img) then
            wg_img_cache[img] = { atlas = trueatlas,image=img}
            return trueatlas,img
        end 
        
        -- wg_no_img_cache[img] = name
		return nil, nil
    end
end

--[[
给定一个图片名，解析其对应的两个资源  
(string)Natlas, (string)Nimage 返回表示图片的两个资源  
atlas (string)图片资源1
img (string)图片资源2
]]
function AssetUtil:ResolveImgPath(atlas, img)
    if wg_img_cache[img] then
        return wg_img_cache[img].atlas,wg_img_cache[img].image
    end
    local Natlas, Nimage = self:WindBellGetImg(atlas, img)
    if Natlas == nil or Nimage == nil then
        assert(nil, string.format("can't find %s-%s correponding atlas or image.", atlas, img))

    end
    return Natlas, Nimage
end


local Img = Class(function(self, atlas, img, no_resolve)
    assert(atlas~=nil, "arguments \"atlas\" can't be nil.")
    self.resolved = no_resolve
    self.atlas = atlas
    self.image = img or atlas
end)

function Img:__tostring()
    return string.format("Img(%s,%s)", self.atlas, self.image)
end

--[[
图片路径处理类，用于返回图片资源路径  
atlas 图片资源1  
img 图片资源2  
no_resolve (bool)在获取时是否解析  
]]
function AssetUtil:MakeImg(atlas, img, no_resolve)
    return Img(atlas, img, no_resolve)
end

--[[
解析图片资源  
]]
function Img:Resolve()
    if not self.resolved then
        self.resolved = true
        self.atlas, self.image = AssetUtil:ResolveImgPath(self.atlas, self.image)
    end
end

--[[
获取图片资源的第二部分  
(string)image 图片资源第二部分  
]]
function Img:GetTex()
    self:Resolve()
    return self.image
end

function Img:GetImage()
    self:Resolve()
    return self.atlas, self.image
end

--[[
获取图片资源路径  
Uimg (Img)图片资源类  
(string)atlas, (string)image 返回这两个资源路径  
]]
function AssetUtil:GetImage(Uimg)
    return Uimg:GetImage()
end

function Img:SetImage(inst)
    assert(inst.components.inventoryitem, string.format("%s don't have inventoryitem component", tostring(inst)))

    local atlas, image = self:GetImage()
    inst.components.inventoryitem.atlasname = atlas
    local img = string.sub(image, 1, -5)
    inst.components.inventoryitem:ChangeImageName(img)
end

--[[
设置物品的物品栏图片  
Uimg (Img)图片资源类  
inst (EntityScript)拥有inventoryitem组件的实体  
]]
function AssetUtil:SetImage(Uimg, inst)
    Uimg:SetImage(inst)
end

return AssetUtil