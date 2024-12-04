local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"
-- local SupportUi = require "widgets/support_ui"
local Spinner = require "widgets/spinner"
local TextEdit = require "widgets/textedit"
local DstGrid = require "extension/uis/dst_grid"
local WgScrollBar = require "extension/uis/wg_scroll_bar"

local HEADERFONT = UIFONT
local BROWN_DARK = {80/255, 61/255, 39/255, 1}
local GOLD = {202/255, 174/255, 118/255, 255/255}

-- 需要的api
-- GetImage 获取图片
-- GetName() 获取预制物名
-- GetScreenName 获取名字
-- GetDescription 获取描述
-- GetIngds 获取材料表（包含材料名，图片工具，堆叠数）
-- GetStack 获取堆叠数
-- GetFn 获取点击函数

local SimpleSpinner = Class(Spinner, function(self, ...)
    Spinner._ctor(self, ...)
    self.leftimage:SetOnClick(function()end)
    self.leftimage.OnGainFocus = function()end
    self.leftimage.OnLoseFocus = function()end
    self.leftimage:Disable()
    self.rightimage:SetOnClick(function()end)
    self.rightimage.OnGainFocus = function()end
    self.rightimage.OnLoseFocus = function()end
    self.rightimage:Disable()
end)

function SimpleSpinner:SetSelectedIndex()
end

function SimpleSpinner:UpdateBG()
end

local function MakeDetailsLine(details_root, x, y, scale, image_override)
	local value_title_line = details_root:AddChild(Image("images/quagmire_recipebook.xml", image_override or "quagmire_recipe_line.tex"))
	value_title_line:SetScale(scale, scale)
	value_title_line:SetPosition(x, y)
end

local CookbookPage = Class(Widget, function(self, data, machine, owner)
    self.owner = owner
    self.machine = machine
    self.data = data
    Widget._ctor(self, "CookbookPage")
    
	-----------
	self.gridroot = self:AddChild(Widget("grid_root"))
    self.gridroot:SetPosition(-180, -35)
    
    self:SetItemPanel()
    
    local boarder_scale = 0.75
    local grid_w, grid_h = 400, 400
    -- 物品面板得上下边框
    -- 上边框
    local grid_boarder = self.gridroot:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_line.tex"))
	grid_boarder:SetScale(boarder_scale, boarder_scale)
    grid_boarder:SetPosition(-3, grid_h/2 + 1)
    -- 下边框
	grid_boarder = self.gridroot:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_line.tex"))
	grid_boarder:SetScale(boarder_scale, -boarder_scale)
    grid_boarder:SetPosition(-3, -grid_h/2)

    -- 物品的信息面板
    local details_decor_root = self:AddChild(Widget("details_root"))
	details_decor_root:SetPosition(grid_w/2 + 30, 0)
    -- 信息面板背景
	local details_decor = details_decor_root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_menu_block.tex"))
    details_decor:ScaleToSize(360, 500)
    -- 左下装饰
	details_decor = details_decor_root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_corner_decoration.tex"))
    details_decor:ScaleToSize(100, 100)
	details_decor:SetPosition(-120, -190)
    -- 右下装饰
	details_decor = details_decor_root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_corner_decoration.tex"))
    details_decor:ScaleToSize(-100, 100)
	details_decor:SetPosition(120, -190)
    -- 将面板赋予self，上面的内容不作为self.details_root的子类，是因为其的子类会被kill
    self.details_root = self:AddChild(Widget("details_root"))
	self.details_root:SetPosition(details_decor_root:GetPosition())
	self.details_root.panel_width = 350
	self.details_root.panel_height = 500
    -- 过滤标签
    self.spinner_root = self.gridroot:AddChild(Widget("spinner_root"))
    self.spinner_root:SetPosition(0, grid_h/2 + 5)
    local height = 25
    local function make_spinner(str)
        local top = 50
        local left = 0
        local width_label = 150
        local width_spinner = 150
        local spacing = 5
		local font = HEADERFONT
		local font_size = 18
		local total_width = width_label + width_spinner + spacing
        local wdg = Widget("labelspinner")
		wdg.label = wdg:AddChild( Text(font, font_size, str) )
		wdg.label:SetPosition( (-total_width/2)+(width_label/2)+25, 0 )
		wdg.label:SetRegionSize( width_label, height )
		wdg.label:SetHAlign( ANCHOR_RIGHT )
		wdg.label:SetColour(unpack(BROWN_DARK))

		local lean = true
		wdg.spinner = wdg:AddChild(SimpleSpinner({}, width_spinner, height, {font = font, size = font_size}, nil, "images/quagmire_recipebook.xml", {
            arrow_normal = "arrow2_left.tex",
            arrow_over = "arrow2_left_over.tex",
            arrow_disabled = "arrow_left_disabled.tex",
            arrow_down = "arrow2_left_down.tex",
            -- arrow_left_normal = "arrow2_left.tex",
            -- arrow_left_over = "arrow2_left_over.tex",
            -- arrow_left_disabled = "arrow_left_disabled.tex",
            -- arrow_left_down = "arrow2_left_down.tex",
            -- arrow_right_normal = "arrow2_right.tex",
            -- arrow_right_over = "arrow2_right_over.tex",
            -- arrow_right_disabled = "arrow_right_disabled.tex",
            -- arrow_right_down = "arrow2_right_down.tex",
            bg_middle = "blank.tex",
            bg_middle_focus = "spinner_focus.tex",
            bg_middle_changing = "blank.tex",
            bg_end = "blank.tex",
            bg_end_focus = "blank.tex",
            bg_end_changing = "blank.tex",
            bg_modified = "option_highlight.tex",
        }))
		wdg.spinner:SetTextColour(unpack(BROWN_DARK))
		-- wdg.spinner:SetOnChangedFn(onchanged_fn)
		wdg.spinner:SetPosition((total_width/2)-(width_spinner/2), 0)
		-- wdg.spinner:SetSelected(initial_data)
        return wdg
    end
    local items = {}
	table.insert(items, make_spinner("制造物品"))
	-- table.insert(items, make_spinner())
    self.spinners = {}
	for i, v in ipairs(items) do
		local w = self.spinner_root:AddChild(v)
		w:SetPosition(50, (#items - i + 1)*(height + 3))
		table.insert(self.spinners, w.spinner)
	end
    self.spinner_image = self.spinners[1]:AddChild(Image())
    self:SetSpinnerInfo()

    -- 解锁物品数量
    local dis_x = -310
	local dis_y = 238
	dis_y = dis_y - 18/2
    self.searcher_bg = self:AddChild( Image() )
	self.searcher_bg:SetTexture( "images/ui.xml", "textbox_long.tex" )
    self.searcher_bg:SetScale(.2, .4)
    self.searcher_bg:SetPosition(dis_x, dis_y)
    self.searcher_bg:SetTint(1, 1, 1, 0)
    self.searcher = self:AddChild(TextEdit(NUMBERFONT, 20, ".."))
    self.searcher_bg.focus_forward = self.searcher
    -- self.searcher:SetFocusedImage( self.searcher_bg, 
    --     "images/ui.xml", "textbox_long_over.tex", "textbox_long.tex" )
    self.searcher.OnTextEntered = function() 
        local str = self.searcher:GetString()
        self:FindItem(str)
    end
    self.searcher:SetColour(unpack(BROWN_DARK))
	self.searcher:SetHAlign(ANCHOR_RIGHT)
    -- local VALID_CHARS = [[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"]]
    -- self.searcher:SetCharacterFilter( VALID_CHARS )
    self.searcher:SetPosition(dis_x, dis_y)

    -- self.test_x = .2
    -- self.test_y = .4
    -- self.test_dt = .1
    -- TheInput:AddKeyDownHandler(KEY_1, function()
    --     if TheInput:IsKeyDown(KEY_CTRL) then
    --         self.test_x = self.test_x + self.test_dt
    --     else 
    --         self.test_x = self.test_x - self.test_dt
    --     end
    --     self.searcher_bg:SetScale(self.test_x, self.test_y)
    -- end)
    -- TheInput:AddKeyDownHandler(KEY_2, function()
    --     if TheInput:IsKeyDown(KEY_CTRL) then
    --         self.test_y = self.test_y + self.test_dt
    --     else 
    --         self.test_y = self.test_y - self.test_dt
    --     end
    --     self.searcher_bg:SetScale(self.test_x, self.test_y)
    -- end)
    -- TheInput:AddKeyDownHandler(KEY_3, function()
    --     print(self.test_x, self.test_y)
    -- end)

	dis_y = dis_y - 18/2
	MakeDetailsLine(self, dis_x, dis_y-4, .5, "quagmire_recipe_line_short.tex")
	dis_y = dis_y - 10
	dis_y = dis_y - 18/2
    local completed = self:AddChild(Text(HEADERFONT, 18, "通过物品代码搜索物品"))
    completed:SetColour(unpack(BROWN_DARK))
    completed:SetHAlign(ANCHOR_RIGHT)
	completed:SetPosition(dis_x, dis_y)
	dis_y = dis_y - 18/2

    -- 名字横条
    local y = 350/2-11 - 34/2 - 34/2 -4
    MakeDetailsLine(self.details_root, 0, y-10, -.55, "quagmire_recipe_line_break.tex")
    -- 名字
    local title = self.details_root:AddChild(Text(HEADERFONT, 34, "未知物品"))
	title:SetColour(unpack(BROWN_DARK))
	title:SetPosition(0, y+4+34/2)
end)

function CookbookPage:FindItem(item_prefab)
    print(item_prefab)
    local child_shelf = self.data:GetCurPagePointItem()
    local item_list = {}
    local page, idx
    for i = child_shelf.cur, child_shelf.max do
        local cur_page = child_shelf.shelf[i]
        for k, item_data in pairs(cur_page) do
            if item_data:GetName() == item_prefab then
                page = i
                idx = k
            end
        end
    end
    if page and idx then
        self.itemboard.scroll_bar:ScrollTo(page)
        local c, r = self.itemboard:FindItemSlot(function(w)
            if w.wg_item == item_prefab then
                return true
            end
        end)
        if c and r then
            local item_slot = self.itemboard:GetItemInSlot(c, r)
            if item_slot then
                item_slot.cell_root.image:SetTexture("images/quagmire_recipebook.xml", "cookbook_known_selected.tex")
            end
        end
    end
end

function CookbookPage:SetIngredient(ingds, y)
    -- ingds
    local ingredient_size = 30
    local x_spacing = 2
    
    local inv_backing_root = self.details_root:AddChild(Widget("inv_backing_root"))
    local inv_item_root = self.details_root:AddChild(Widget("inv_item_root"))
    local index = 1
    
    local shelf = {{}}
    local count = 0
    local cur = 1
    for k, v in pairs(ingds) do
        table.insert(shelf[cur], v)
        count = count + 1
        if count >= 8 then
            count = 0
            table.insert(shelf, {})
            cur = cur + 1
        end
    end
    local function make_ingredient(item_data, x, y)
        -- 背景卡槽
        local backing = inv_backing_root:AddChild(Image("images/quagmire_recipebook.xml", "ingredient_slot.tex"))
        backing:ScaleToSize(ingredient_size, ingredient_size)
        backing:SetPosition(x, y)
        -- local img = inv_item_root:AddChild(Image(img_atlas or "images/quagmire_recipebook.xml", img_atlas ~= nil and img_name or "cookbook_missing.tex"))
        -- local item_data = item_raw[i]
        local img = inv_backing_root:AddChild(Image(item_data:GetImage()))
        -- img:ScaleToSize(ingredient_size, ingredient_size)
        img:SetScale(.5, .5, .5)  -- 不同的图片scaleToSize改变的长款尺寸不一样，会影响到字体
        img:SetPosition(backing:GetPosition())
        -- local img_info = inv_backing_root:AddChild(Widget("img_info"))
        -- img_info:SetPosition(backing:GetPosition())
        img.stack = img:AddChild(Text(NUMBERFONT, 30, string.format("x%d", item_data:GetStack())))
        img.stack:SetPosition(25, -25, 0)
        img.OnGainFocus = function(w)
            w.hover_txt = img:AddChild(Text(UIFONT, 30, item_data:GetScreenName()))
            w.hover_txt:SetPosition(0, 20, 0)
        end
        img.OnLoseFocus = function(w)
            w.hover_txt:Kill()
        end
    end
    if #shelf <= 3 then
        for b = 1, #shelf do
            local item_raw = shelf[index]
            local x = -((#item_raw + 1)*ingredient_size + (#item_raw-1)*x_spacing) / 2
            for i = 1, #item_raw do
                local item_data = item_raw[i]
                local px, py = x + (i)*ingredient_size + (i-1)*x_spacing, y - ingredient_size/2 - (b-1)*(ingredient_size+5)
                make_ingredient(item_data, px, py)
            end
            index = index + 1
        end
    else
        local width = ((4)*ingredient_size + (4-1)*x_spacing)
        local column_spacing_offset = 5
        for b = 1, #shelf do
            local item_raw = shelf[index]
            local x = (b%2 == 1) and (-width - ingredient_size + column_spacing_offset) or -column_spacing_offset
            for i = 1, #item_raw do
                local item_data = item_raw[i]
                local px, py = x + (i)*ingredient_size + (i-1)*x_spacing, y - ingredient_size/2 - (b-1)*(ingredient_size+5)
                make_ingredient(item_data, px, py)
            end
            index = index + 1
        end
    end
end

function CookbookPage:SetInfoPanel(item_data)
    local top = self.details_root.panel_height/2
	local left = -self.details_root.panel_width / 2

	local details_root = Widget("details_root")

	local y = top - 11

	local image_size = 110

	local name_font_size = 34
	local title_font_size = 18 --22
	local body_font_size = 16 --18
	local value_title_font_size = 18
	local value_body_font_size = 16

	y = y - name_font_size/2
    -- local name_data = item_data:GetScreenName()
    local name_data = ""
	local title = details_root:AddChild(Text(HEADERFONT, name_font_size, name_data))
	title:SetColour(unpack(BROWN_DARK))
	title:SetPosition(0, y)
	y = y - name_font_size/2 - 4
	MakeDetailsLine(details_root, 0, y-10, -.55, "quagmire_recipe_line_break.tex")
	y = y - 30
		local icon_size = image_size - 20
		local frame = details_root:AddChild(Image("images/quagmire_recipebook.xml", "cookbook_known.tex"))
		frame:ScaleToSize(image_size, image_size)
		y = y - image_size/2
		frame:SetPosition(left + image_size/2 + 30, y)
		y = y - image_size/2

		local portrait_root = details_root:AddChild(Widget("portrait_root"))
		portrait_root:SetPosition(frame:GetPosition())

		-- local food_img = portrait_root:AddChild(Image(data.food_atlas, not data.unlocked and "cookbook_unknown.tex" or data.food_tex))
        local food_img = portrait_root:AddChild(Image(item_data:GetImage()))
		-- food_img:ScaleToSize(icon_size, icon_size)
        food_img:SetScale(icon_size/64)
        food_img.stack = food_img:AddChild(Text(NUMBERFONT, 20, string.format("x%d", item_data:GetStack())))
        food_img.stack:SetPosition(25, -25, 0)

		local details_x = 60
			local details_y = y + 85
			local status_scale = 0.7
			details_y = details_y - 42
			-- Side Effects
				details_y = details_y - value_title_font_size/2
                -- title = details_root:AddChild(Text(HEADERFONT, value_title_font_size, "物品代码"))
                -- title:SetColour(unpack(BROWN_DARK))
				-- title:SetPosition(details_x, details_y+20)

                -- local name_data2 = item_data:GetName()
                local name_data2 = item_data:GetScreenName()
				title = details_root:AddChild(Text(NUMBERFONT, 30, name_data2))
                title:SetColour(unpack(BROWN_DARK))
				title:SetPosition(details_x, details_y+30-value_title_font_size)
				details_y = details_y - value_title_font_size/2
				MakeDetailsLine(details_root, details_x, details_y - 2, .5, "quagmire_recipe_line_short.tex")
				details_y = details_y - 8
				details_y = details_y - value_body_font_size/2
				-- local effects = details_root:AddChild(Text(HEADERFONT, value_body_font_size, "物品代码"))
				local effects = details_root:AddChild(Text(HEADERFONT, value_body_font_size, "物品名称"))
                effects:SetColour(unpack(BROWN_DARK))
                -- effects:SetMultilineTruncatedString(effects_str, 1, 190, nil, "...")
				effects:SetPosition(details_x, details_y)
				details_y = details_y - value_body_font_size/2 - 4
		y = y - 12

		local row_start_y = y
		local column_offset_x = 80
		-- Food Type
		y = y - title_font_size/2
		-- title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.COOKBOOK.FOOD_TYPE_TITLE, BROWN_DARK))
		-- title:SetPosition(-column_offset_x, y)
        title = details_root:AddChild(Text(HEADERFONT, title_font_size, "介绍"))
        title:SetColour(unpack(BROWN_DARK))
        -- local title_w, title_h = title:GetRegionSize()
        title:SetPosition(0, y)

		y = y - title_font_size/2
		-- MakeDetailsLine(details_root, -column_offset_x, y - 2, .5, "quagmire_recipe_line_veryshort.tex")
        MakeDetailsLine(details_root, 0, y - 2, .49)
        local desc = details_root:AddChild(Text(NUMBERFONT, title_font_size, item_data:GetDescription()))
        local desc_w, desc_h = desc:GetRegionSize()
        desc:SetPosition(0, y-8-desc_h/2)
        local desc_y = y-8-desc_h/2  -- 用于下面的调整位置
        -- desc:SetColour(unpack(BROWN_DARK))  -- 看不清

        y = y - 8
		y = y - body_font_size/2
		-- local str = STRINGS.UI.FOOD_TYPES[data.recipe_def.foodtype or FOODTYPE.GENERIC]  or STRINGS.UI.COOKBOOK.FOOD_TYPE_UNKNOWN
		-- local tags = details_root:AddChild(Text(HEADERFONT, body_font_size, str, BROWN_DARK))
		-- tags:SetPosition(-column_offset_x, y)
		y = y - body_font_size/2 - 4
		y = row_start_y
		-- Perish Rate
		y = y - title_font_size/2
		-- title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.COOKBOOK.PERISH_RATE_TITLE, BROWN_DARK))
		-- title:SetPosition(column_offset_x, y)
		y = y - title_font_size/2
		-- MakeDetailsLine(details_root, column_offset_x, y - 2, .5, "quagmire_recipe_line_veryshort.tex")
		y = y - 8
		y = y - body_font_size/2
		-- local str = self:_GetSpoilString(data.recipe_def.perishtime)
		-- local tags = details_root:AddChild(Text(HEADERFONT, body_font_size, str, BROWN_DARK))
		-- tags:SetPosition(column_offset_x, y)
		y = y - body_font_size/2 - 4
		y = y - 10
        local ingds = item_data:GetIngds()
		-- if data.recipes ~= nil and #data.recipes > 0 then
        if ingds and #ingds>0 then
			-- Cooking Time
			y = y - title_font_size/2
			-- title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.COOKBOOK.COOKINGTIME_TITLE, BROWN_DARK))
			-- title:SetPosition(0, y)
			y = y - title_font_size/2
			-- MakeDetailsLine(details_root, 0, y - 2, .49)
			y = y - 8
			y = y - body_font_size/2 - 4
			-- local str = self:_GetCookingTimeString(data.recipes ~= nil and data.recipe_def.cooktime or nil)
			-- local tags = details_root:AddChild(Text(HEADERFONT, body_font_size, str, BROWN_DARK))
			-- tags:SetPosition(0, y)
			y = y - body_font_size/2 - 4
			y = y - 10
			-- INGREDIENTS
			y = y - title_font_size/2
			-- title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.RECIPE_BOOK.DETAILS_LABEL_RECIPES, BROWN_DARK))
            local str = self.machine.wg_compos_book_detail_string or "制作材料"
            title = details_root:AddChild(Text(HEADERFONT, title_font_size, str))
            title:SetColour(unpack(BROWN_DARK))
            -- 如果描述太长，则需要根据描述的范围确定位置
            local dst_y = desc_y - desc_h/2 - 10
            y = math.min(dst_y, y)

            title:SetPosition(0, y)
			y = y - title_font_size/2
			MakeDetailsLine(details_root, 0, y - 2, .49)
			y = y - 10
			self:SetIngredient(ingds, y)
		else
			y = y - title_font_size/2
			-- title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.COOKBOOK.NO_RECIPES_TITLE, BROWN_DARK))
            local str = self.machine.wg_compos_book_detail_string or "制作材料"
            title = details_root:AddChild(Text(HEADERFONT, title_font_size, str))
            title:SetColour(unpack(BROWN_DARK))
            title:SetPosition(0, y)
			y = y - title_font_size/2
			MakeDetailsLine(details_root, 0, y - 2, .49)
			y = y - 10
			y = y - body_font_size/2
			-- local body = details_root:AddChild(Text(HEADERFONT, body_font_size, "", BROWN_DARK))
			-- body:SetMultilineTruncatedString(STRINGS.UI.COOKBOOK.NO_RECIPES_DESC, 20, 300)
			-- local _, msg_h = body:GetRegionSize()
			-- y = y - msg_h/2
			-- body:SetPosition(0, y)
		end
    self.details_root:AddChild(details_root)
end

function CookbookPage:GetItemList()
    local child_shelf = self.data:GetCurPagePointItem()
    -- local item_matrix = child_shelf:GetAllPageItemMatrix()
	-- local item_list = child_shelf:GetAllPageItemList()
    local item_list = {}
    for i = child_shelf.cur, child_shelf.max do
        for k, v in pairs(child_shelf.shelf[i]) do
            table.insert(item_list, v)
        end
    end
    return item_list
end

function CookbookPage:GetItemWidgetList()
    local base_size = 128
    local cell_size = 73
    local function make_item(item_data, index)
        local w = Widget("recipe-cell-".. index)
		----------------
        w.wg_item = item_data:GetName()
		-- w.cell_root = w:AddChild(ImageButton("images/quagmire_recipebook.xml", "cookbook_unknown.tex", "cookbook_unknown_selected.tex"))
		w.cell_root = w:AddChild(ImageButton("images/quagmire_recipebook.xml", "cookbook_known.tex", "cookbook_known_selected.tex"))
		w.cell_root:SetScale(cell_size/base_size, cell_size/base_size)
		w.focus_forward = w.cell_root
		----------------
		w.recipe_root = w.cell_root.image:AddChild(Widget("recipe_root"))

		-- 这里是物品的图片，预先随便给了一个图片素材填充
        -- w.food_img = w.recipe_root:AddChild(Image("images/global.xml", "square.tex")) -- this will be replaced with the food icon
        w.food_img = w.recipe_root:AddChild(Image(item_data:GetImage()))
        -- w.desc = w.recipe_root:AddChild(Text(NUMBERFONT))
        -- w.desc:SetString(item_data:GetExDesc())

		-- w.partiallyknown_icon = w.recipe_root:AddChild(Image("images/quagmire_recipebook.xml", "cookbook_unknown_icon.tex"))
		-- w.partiallyknown_icon:ScaleToSize(icon_size, icon_size)
        -- w.partiallyknown_icon:SetPosition(-base_size/2 + 22, base_size/2 - 25)

		w.cell_root:SetOnClick(function()
			self.details_root:KillAllChildren()
            self:SetInfoPanel(item_data)
            self:SetSpinnerInfo()
            local fn = item_data:GetFn()
            fn(self)
        end)
		----------------
		return w
    end
    
    local item_list = self:GetItemList()
    local widgets = {}
	for i = 1, 25 do
        local item_data = item_list[i]
        local idx = i
        if item_data then
            table.insert(widgets, make_item(item_data, idx))
        else
            break
        end
	end
    return widgets
end

function CookbookPage:SetSpinnerInfo()
    if self.spinner_image then
        local atlas, image = self.data:GetSpinnerInfo(self.machine, self.owner)
		if atlas and image then
			self.spinner_image:SetTexture(atlas, image)
            self.spinner_image:ScaleToSize(30, 30)
		end
	end
    -- self.spinner_image:SetTexture(item_data:GetImage())
end

function CookbookPage:SetItemPanel()
    local base_size = 128
    local cell_size = 73
    local row_w = cell_size
    local row_h = cell_size;
    local reward_width = 80
    local row_spacing = 5

	local food_size = cell_size + 20
	local icon_size = 20 / (cell_size/base_size)
	
    -- local child_shelf = self.data:GetCurPagePointItem()
    -- local item_matrix = child_shelf:GetAllPageItemMatrix()
	-- -- local item_list = child_shelf:GetAllPageItemList()
    -- local item_list = {}
    -- for i = child_shelf.cur, child_shelf.max do
    --     for k, v in pairs(child_shelf.shelf[i]) do
    --         table.insert(item_list, v)
    --     end
    -- end
    -- local item_list = self:GetItemList()
    local child_shelf = self.data:GetCurPagePointItem()
	local scroll_bar_max = math.max(1, child_shelf.max-4)
    local scroll_bar_cur = child_shelf.cur

    local widgets = self:GetItemWidgetList()
    -- colmn num = item_matrix.max
    -- 1 page = items of 1 row
    -- local grid = Widget("Grid")
	local grid = DstGrid()
    self.itemboard = self.gridroot:AddChild(grid)
	local opts = {
		widget_width  = row_w+row_spacing,
		widget_height = row_h+row_spacing,
		force_peek    = true,
		num_visible_rows = 5,
		num_columns      = 5,
		scrollbar_offset = 20,
		scrollbar_height_offset = -60
	}
    local peek_height = opts.widget_height*0.25
    local scissor_pad = opts.scissor_pad or 0
    local scissor_width  = opts.widget_width  * opts.num_columns      + scissor_pad
    local scissor_height = opts.widget_height * opts.num_visible_rows + peek_height
    local scissor_x = -scissor_width/2
    local scissor_y = -scissor_height/2
	
	grid:FillGrid(opts.num_columns, opts.widget_width, opts.widget_height, widgets)
    
	grid:SetPosition(-opts.widget_width * (opts.num_columns-1)/2-15, opts.widget_height * (opts.num_visible_rows-1)/2 + peek_height/2-5)
    grid.scroll_bar = grid:AddChild(WgScrollBar(scroll_bar_max))
    grid.scroll_bar.cur = scroll_bar_cur
    grid.scroll_bar:OnScroll()
    grid.scroll_bar.on_scroll = function(my)
        self:OnScroll()
    end
    -- 上物品陈列面板里也可以上下滑动
    -- grid.OnControl = function(my, control, down)
    --     return grid.scroll_bar:OnControl(control, down)
    -- end
    -- grid.scroll_bar:SetPosition(scissor_x + scissor_width + opts.scrollbar_offset, scissor_y + scissor_height/2)
    grid.scroll_bar:SetPosition(375, -160)
    local arrow_button_size = 30
    local nudge_y = arrow_button_size/3
    local scrollbar_height = scissor_height + opts.scrollbar_height_offset
    grid.scroll_bar.up_button:SetPosition(0, scrollbar_height/2 + nudge_y/2)
    grid.scroll_bar.down_button:SetPosition(0, -scrollbar_height/2 - nudge_y/2)
    local line_height = scrollbar_height - arrow_button_size/2
    local bar_width_scale_factor = 1
    grid.scroll_bar.scroll_bar_line:ScaleToSize(11*bar_width_scale_factor, line_height)
    grid.scroll_bar.data[1][2] = line_height/2

	grid.scroll_bar.up_button:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    grid.scroll_bar.up_button:SetScale(0.5)

	grid.scroll_bar.down_button:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    grid.scroll_bar.down_button:SetScale(-0.5)

	grid.scroll_bar.scroll_bar_line:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
	grid.scroll_bar.scroll_bar_line:SetScale(.8)

	grid.scroll_bar.position_marker:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
	grid.scroll_bar.position_marker.image:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    grid.scroll_bar.position_marker:SetScale(.6)

end

function CookbookPage:OnScroll()
    local grid = self.itemboard
    local my = grid.scroll_bar
    local cur = my.cur
    local child_shelf = self.data:GetCurPagePointItem()
    child_shelf.cur = cur
    grid:Clear()
    local widgets = self:GetItemWidgetList()
    grid:FillGrid(5, 73+5, 73+5, widgets)
end

local CookbookWidget = Class(Widget, function(self, data, machine, owner)
    self.owner = owner
    self.machine = machine
    self.data = data
    Widget._ctor(self, "CookbookWidget")
    self.root = self:AddChild(Widget("root"))
	
    self.tabs = {}
    self:Init()
end)

function CookbookWidget:Init()
    self:SetTabs()
    self.backdrop = self.root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_menu_bg.tex"))
    self.backdrop:ScaleToSize(900, 550)
    local idx = self.data:GetPoint()
    self:SelectTab(idx)
end

function CookbookWidget:SelectTab(idx)
    self.data:SetPoint(idx)
    local tab = self.tabs[idx]
    if self.last_selected ~= tab then
        tab:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_active.tex")
        self.last_selected = tab
        self.tabs[idx]:MoveToBack()
        for k, v in pairs(self.tabs) do
            if k ~= idx then
                self.tabs[k]:MoveToBack()
                self.tabs[k]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")
            end
        end
        self:SetPanel()
    end
    -- self.focus_forward = self.panel.parent_default_focus
end

function CookbookWidget:TabsPageTurn(dt)
    self.data:PageTurn(dt)
    self:SetPanel()
end

function CookbookWidget:SetTabs()
    for k, v in pairs(self.tabs) do
        v:Kill()
    end
    self.tabs = {}
    self.last_selected = nil
    local base_size = .7
    local function make_tab(shelf, idx)
        local tab = ImageButton("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex")
		tab:SetScale(base_size, base_size)
        tab:SetText(shelf.title)
        tab:SetTextSize(22)
        tab:SetFont(HEADERFONT)
        tab:SetTextColour(unpack(GOLD))
        tab:SetTextFocusColour(1,1,1,1)
        tab.text:SetPosition(0, -2)
        -- tab.clickoffset = Vector3(0,5,0)
        tab.idx = idx
        tab:SetOnClick(function()
            self:SelectTab(tab.idx)
        end)
		return tab
    end
    -- 设置翻页键
    self.tabs.page_up = self.root:AddChild(ImageButton("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex"))
	self.tabs.page_up:SetScale(base_size-.1, base_size-.1)
    self.tabs.page_up:SetText("上一页")
    self.tabs.page_up:SetTextSize(25)
    self.tabs.page_up:SetFont(HEADERFONT)
    self.tabs.page_up:SetTextColour(unpack(GOLD))
    self.tabs.page_up:SetOnClick(function()
        self.data:PageTurn(-1)
        self:SetTabs()
        local idx = self.data:GetPoint()
        self:SelectTab(idx)
    end)
    self.tabs.page_down = self.root:AddChild(ImageButton("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex"))
	self.tabs.page_down:SetScale(base_size-.1, base_size-.1)
    self.tabs.page_down:SetText("下一页")
    self.tabs.page_down:SetTextSize(25)
    self.tabs.page_down:SetFont(HEADERFONT)
    self.tabs.page_down:SetTextColour(unpack(GOLD))
    self.tabs.page_down:SetOnClick(function()
        self.data:PageTurn(1)
        self:SetTabs()
        local idx = self.data:GetPoint()
        self:SelectTab(idx)
    end)
    -- 
    local shelfs = self.data:GetItems()
    for k, v in pairs(shelfs) do
        table.insert(self.tabs, self.root:AddChild(make_tab(v, k)))
    end

    -- 设置位置
    local len = #self.tabs
    local offset = #self.tabs / 2
    for i = 1, #self.tabs do
        local x = (i - offset - 0.5) * 200
        self.tabs[i]:SetPosition(x, 285)
    end
    -- 设置翻页键位置
    local pos = self.tabs[1]:GetPosition()
    self.tabs.page_up:SetPosition(pos.x-80, pos.y)
    self.tabs.page_up.text:SetPosition(-115, -2)
    
    local pos = self.tabs[len]:GetPosition()
    self.tabs.page_down:SetPosition(pos.x+80, pos.y)
    self.tabs.page_down.text:SetPosition(115, -2)
    
    -- if self.backdrop then
	-- 	self.root:RemoveChild(self.backdrop)
	-- 	self.root:AddChild(self.backdrop)
	-- end
end

function CookbookWidget:SetPanel()
    if self.panel ~= nil then
        self.panel:Kill()
    end
    -- local item_raw = self.data:GetItems():GetItems()
    self.panel = self.root:AddChild(CookbookPage(self.data, self.machine, self.owner))
end

local WgCookbook = Class(Screen, function(self, data, machine, owner)
    self.owner = owner
    self.machine = machine
    self.data = data
    Screen._ctor(self, "WgCookbook")

    SetPause(true)
    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black.image:SetVRegPoint(ANCHOR_MIDDLE)
    black.image:SetHRegPoint(ANCHOR_MIDDLE)
    black.image:SetVAnchor(ANCHOR_MIDDLE)
    black.image:SetHAnchor(ANCHOR_MIDDLE)
    black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    black.image:SetTint(0,0,0,.5)
    black:SetOnClick(function() 
        SetPause(false)
        TheFrontEnd:PopScreen() 
    end)
    -- black:SetHelpTextMessage("")

	local root = self:AddChild(Widget("root"))
	root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetVAnchor(ANCHOR_MIDDLE)
	root:SetPosition(0, -25)

    self.book = root:AddChild(CookbookWidget(data, machine, owner))
end)

return WgCookbook