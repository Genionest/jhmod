local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local EntUtil = require "extension.lib.ent_util"

AddClassPostConstruct("widgets/controls", function(self)
    self.tp_equip_skill_root = self:AddChild(Widget("TpEquipSkillRoot"))

    self.tp_equip_skill_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.tp_equip_skill_root:SetHAnchor(ANCHOR_LEFT)
    self.tp_equip_skill_root:SetVAnchor(ANCHOR_BOTTOM)
    local MAX_HUD_SCALE = 1.25
    self.tp_equip_skill_root:SetMaxPropUpscale(MAX_HUD_SCALE)

    self.tp_equip_skill_bg = {}
    self.tp_equip_skill_value = {}
    self.tp_equip_skill_slots = {}

    local equip_skill_slots_info = {
        [EQUIPSLOTS.HANDS] = {
            x = 150,
            img = {"images/hud.xml", "equip_slot.tex"}
        },
        [EQUIPSLOTS.BODY] = {
            x = 110,
            img = {"images/hud.xml", "equip_slot_body.tex"}
        },
        [EQUIPSLOTS.HEAD] = {
            x = 70,
            img = {"images/hud.xml", "equip_slot_head.tex"}
        },
    }
    for k, v in pairs(equip_skill_slots_info) do
        self.tp_equip_skill_bg[k] = self.tp_equip_skill_root:AddChild(
            Image(unpack(v.img)))
        self.tp_equip_skill_bg[k]:SetPosition(v.x, 70, 0)
        self.tp_equip_skill_bg[k]:SetScale(.6, .6, .6)
        local key_txt = self.tp_equip_skill_bg[k]:AddChild(Text(TITLEFONT, 30))
        key_txt:SetPosition(0, -50, 0)
        local key_value = GetModConfigData(k.."_key")
        local nkey_set = {"RSHIFT", "LSHIFT", "RCTRL", "LCTRL", "RALT", "LALT"}
        if key_value <= 97+25 then
            key_txt:SetString(string.char( key_value-(97-65) ))
        elseif key_value >= 303 then
            key_txt:SetString(nkey_set[key_value-303+1])
        end

        self.tp_equip_skill_value[k] = self.tp_equip_skill_root:AddChild(UIAnim())
        self.tp_equip_skill_value[k]:GetAnimState():SetBank("obsidian_tool_meter")
        self.tp_equip_skill_value[k]:GetAnimState():SetBuild("obsidian_tool_meter")
        self.tp_equip_skill_value[k]:GetAnimState():SetPercent("anim", 0)
        self.tp_equip_skill_value[k]:SetPosition(v.x, 70, 0)
        self.tp_equip_skill_value[k]:SetScale(.6, .6, .6)

        self.tp_equip_skill_slots[k] = self.tp_equip_skill_root:AddChild(
            ImageButton("images/inventoryimages.xml", "ash.tex"))
        self.tp_equip_skill_slots[k]:SetPosition(v.x, 70, 0)
        self.tp_equip_skill_slots[k]:SetScale(.6, .6, .6)
        self.tp_equip_skill_slots[k]:Hide()
    end

    local function show_equip_skill_ui(item, slot)
        if self.tp_equip_skill_slots[slot] == nil then
            return
        end
        local btn = self.tp_equip_skill_slots[slot]
        btn.equip = item
        local atlas = item.components.inventoryitem:GetAtlas()
        local img = item.components.inventoryitem:GetImage()
        btn:SetOnClick(function()
            item.components.wg_action_tool:ClickSkillButton(self.owner)
        end)
        btn.GetWargonString = function()
            return item.components.wg_action_tool:GetSkillDesc(self.owner)
        end
        btn.GetWargonStringColour = function()
            return item.components.wg_action_tool:GetSkillDescColour(self.owner)
        end
        btn:SetTextures(atlas, img)
        btn:Show()

        -- change image
        btn.event_img_fn = EntUtil:listen_for_event(btn.inst, "imagechange", function(inst, data)
            local atlas = item.components.inventoryitem:GetAtlas()
            local img = item.components.inventoryitem:GetImage()
            btn:SetTextures(atlas, img)
        end, btn.equip)

        -- equip value
        if item.components.tp_equip_value then
            local meter = self.tp_equip_skill_value[slot]
            if meter then
                if not meter.shown then
                    meter:Show()
                end
                local p = item.components.tp_equip_value:GetPercent()
                meter:GetAnimState():SetPercent("anim", p)
                meter.event_value_fn = EntUtil:listen_for_event(meter.inst, "tp_equip_value_delta", function(inst, data)
                    meter:GetAnimState():SetPercent("anim", data.new_p)
                end, item)
            end
        end
    end
    local function hide_equip_skill_ui(item, slot)
        if self.tp_equip_skill_slots[slot] == nil then
            return
        end
        local btn = self.tp_equip_skill_slots[slot]
        -- change image
        if btn.event_img_fn then
            btn.inst:RemoveEventCallback("imagechange", btn.event_img_fn, btn.equip)
            btn.event_img_fn = nil
        end

        btn.equip = nil
        btn.onclick = nil
        btn.GetWargonString = nil
        btn:Hide()

        local meter = self.tp_equip_skill_value[slot]
        if meter.shown then
            meter:Hide()
        end
        if meter.event_value_fn then
            meter.inst:RemoveEventCallback("tp_equip_value_delta", meter.event_value_fn, item)
            meter.event_value_fn = nil
        end
    end

    self.inst:ListenForEvent("equip", function(inst, data)
        if data and data.item and data.item.components.wg_action_tool then
            show_equip_skill_ui(data.item, data.eslot)
        end
    end, self.owner)
    self.inst:ListenForEvent("unequip", function(inst, data)
        if data and data.item and data.item.components.wg_action_tool then
            hide_equip_skill_ui(data.item, data.eslot)
        end
    end, self.owner)
    for k, v in pairs(equip_skill_slots_info) do
        local item = self.owner.components.inventory:GetEquippedItem(k)
        if item and item.components.wg_action_tool then
            show_equip_skill_ui(item, k)
        end
    end
end)

-- 技能快捷键
AddPlayerPostInit(function(inst)
    local function equip_skill_trigger(slot)
        local controls = inst.HUD and inst.HUD.controls
        if controls.tp_equip_skill_slots then
            local ui = controls.tp_equip_skill_slots[slot] 
            if ui.onclick then
                ui.onclick()
            end
        end
    end
    TheInput:AddKeyDownHandler(GetModConfigData("hands_key"), function()
        if not IsPaused() then
            equip_skill_trigger(EQUIPSLOTS.HANDS)
        end
    end)
    TheInput:AddKeyDownHandler(GetModConfigData("body_key"), function()
        if not IsPaused() then
            equip_skill_trigger(EQUIPSLOTS.BODY)
        end
    end)
    TheInput:AddKeyDownHandler(GetModConfigData("head_key"), function()
        if not IsPaused() then
            equip_skill_trigger(EQUIPSLOTS.HEAD)
        end
    end)
end)