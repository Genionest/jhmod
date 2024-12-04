local Image = require "widgets/image"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"
-- local SupportUi = require "widgets/support_ui"
local WgMenu = require "datas/uis/widget_menu"
-- local WgBlackboard = require "datas/uis/widget_blackboard"
local Spinner = require "widgets/spinner"
local Grid = require "widgets/grid"
local DstGrid = require "widgets/dst_grid"
-- local TrueScrollList = require "widgets/truescrolllist"
local WgScrollBar = require "widgets/wg_scroll_bar"
local TextEdit = require "widgets/textedit"

-- 制作确认升级按钮

local HEADERFONT = UIFONT
local BROWN_DARK = {80/255, 61/255, 39/255, 1}
local GOLD = {202/255, 174/255, 118/255, 255/255}

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

local ExhibitionbookPage = Class(Widget, function(self, data, owner)
    self.owner = owner
    self.data = data
    Widget._ctor(self, "ExhibitionbookPage")

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
            bg_middle = "blank.tex",
            bg_middle_focus = "spinner_focus.tex",
            bg_middle_changing = "blank.tex",
            bg_end = "blank.tex",
            bg_end_focus = "blank.tex",
            bg_end_changing = "blank.tex",
            bg_modified = "option_highlight.tex",
        }))
		wdg.spinner:SetTextColour(unpack(BROWN_DARK))
		wdg.spinner:SetPosition((total_width/2)-(width_spinner/2), 0)
        return wdg
    end
    local items = {}
	-- table.insert(items, make_spinner(""))
	table.insert(items, make_spinner("剩余精华"))
    self.spinners = {}
	for i, v in ipairs(items) do
		local w = self.spinner_root:AddChild(v)
		w:SetPosition(50, (#items - i + 1)*(height + 3))
		table.insert(self.spinners, w.spinner)
		-- table.insert(self.spinners, w.label)
	end

    self.spinner_image = self.spinners[1]:AddChild(Image())
    self.spinner_txt = self.spinner_image:AddChild(Text(NUMBERFONT, 30))
    self:SetSpinnerInfo()

    -- 解锁物品数量
    local dis_x = -310
	local dis_y = 238
    dis_y = dis_y - 18/2
    --
    dis_y = dis_y - 18/2
	MakeDetailsLine(self, dis_x, dis_y-4, .5, "quagmire_recipe_line_short.tex")
	dis_y = dis_y - 10
	dis_y = dis_y - 18/2

    dis_y = dis_y - 18/2

    -- 名字横条
    local y = 350/2-11 - 34/2 - 34/2 -4
    MakeDetailsLine(self.details_root, 0, y-10, -.55, "quagmire_recipe_line_break.tex")
    -- 名字
    local title = self.details_root:AddChild(Text(HEADERFONT, 34, "未知属性"))
	title:SetColour(unpack(BROWN_DARK))
	title:SetPosition(0, y+4+34/2)
end)

function ExhibitionbookPage:SetIngredient(ingds, y)
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
        local img_data = item_data.img
        local img = inv_item_root:AddChild(Image(WARGON:resolve_img_path(img_data)))
        img:ScaleToSize(ingredient_size, ingredient_size)
        img:SetPosition(backing:GetPosition())
        img.stack = img:AddChild(Text(NUMBERFONT, 30, string.format("x%d", item_data.stack)))
        img.stack:SetPosition(25, -25, 0)
        img.OnGainFocus = function(w)
            w.hover_txt = img:AddChild(Text(UIFONT, 30, item_data.name))
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

function ExhibitionbookPage:GetItemList()
    -- local child_shelf = self.data:GetCurPagePointItem()
    local child_shelf = self.data
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

function ExhibitionbookPage:GetItemWidgetList()
    local base_size = 128
    local cell_size = 73
    local function make_item(item_data, index)
        -- WARGON:traverse(item_data)
        local w = Widget("recipe-cell-".. index)
		----------------
        w.wg_item = item_data.name
		-- w.cell_root = w:AddChild(ImageButton("images/quagmire_recipebook.xml", "cookbook_unknown.tex", "cookbook_unknown_selected.tex"))
		w.cell_root = w:AddChild(ImageButton("images/quagmire_recipebook.xml", "cookbook_known.tex", "cookbook_known_selected.tex"))
		w.cell_root:SetScale(cell_size/base_size, cell_size/base_size)
		w.focus_forward = w.cell_root
		----------------
		w.recipe_root = w.cell_root.image:AddChild(Widget("recipe_root"))

		-- 这里是物品的图片，预先随便给了一个图片素材填充
        -- w.food_img = w.recipe_root:AddChild(Image("images/global.xml", "square.tex")) -- this will be replaced with the food icon
        w.food_img = w.recipe_root:AddChild(Image(item_data:GetImg()))
        w.desc = w.recipe_root:AddChild(Text(NUMBERFONT, 30))
        w.desc:SetString(item_data:GetExDesc(self))

		-- w.partiallyknown_icon = w.recipe_root:AddChild(Image("images/quagmire_recipebook.xml", "cookbook_unknown_icon.tex"))
		-- w.partiallyknown_icon:ScaleToSize(icon_size, icon_size)
        -- w.partiallyknown_icon:SetPosition(-base_size/2 + 22, base_size/2 - 25)

		w.cell_root:SetOnClick(function()
            xpcall(function()
                self.details_root:KillAllChildren()
                self:SetInfoPanel(item_data)
                self:SetSpinnerInfo()
                local fn = item_data:GetFn()
                fn(self, w)
            end, function(error)
                print(error)
            end)
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

function ExhibitionbookPage:SetSpinnerInfo()
    if self.spinner_image and self.spinner_txt then
        local img, txt = self.data:GetSpinnerInfo(self.owner)
        if img then
            self.spinner_image:SetTexture(WARGON:resolve_img_path(img))
            self.spinner_image:ScaleToSize(30, 30)
        end
        self.spinner_txt:SetString(txt)
    end
    -- self.product:SetTexture(item_data:GetImg())
end

function ExhibitionbookPage:SetItemPanel()
    local base_size = 128
    local cell_size = 73
    local row_w = cell_size
    local row_h = cell_size;
    local reward_width = 80
    local row_spacing = 5

	local food_size = cell_size + 20
	local icon_size = 20 / (cell_size/base_size)
	
    -- local child_shelf = self.data:GetCurPagePointItem()
    local child_shelf = self.data
	local scroll_bar_max = math.max(1, child_shelf.max-4)
    local scroll_bar_cur = child_shelf.cur

    local widgets = self:GetItemWidgetList()
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

function ExhibitionbookPage:OnScroll()
    local grid = self.itemboard
    local my = grid.scroll_bar
    local cur = my.cur
    -- local child_shelf = self.data:GetCurPagePointItem()
    local child_shelf = self.data
    child_shelf.cur = cur
    grid:Clear()
    local widgets = self:GetItemWidgetList()
    grid:FillGrid(5, 73+5, 73+5, widgets)
end

function ExhibitionbookPage:SetInfoPanel(item_data)
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
    local name_data = item_data:GetName()
	-- local title = details_root:AddChild(Text(HEADERFONT, name_font_size, name_data))
	local title = details_root:AddChild(Text(HEADERFONT, name_font_size, "属性介绍"))
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
        local food_img = portrait_root:AddChild(Image(item_data:GetImg()))
		food_img:ScaleToSize(icon_size, icon_size)

		local details_x = 60
			local details_y = y + 85
			local status_scale = 0.7
			details_y = details_y - 42
			-- Side Effects
				details_y = details_y - value_title_font_size/2
                -- title = details_root:AddChild(Text(HEADERFONT, value_title_font_size, "物品代码"))
                -- title:SetColour(unpack(BROWN_DARK))
				-- title:SetPosition(details_x, details_y+20)

				title = details_root:AddChild(Text(NUMBERFONT, 30, item_data:GetName()))
                title:SetColour(unpack(BROWN_DARK))
				title:SetPosition(details_x, details_y+30-value_title_font_size)
				details_y = details_y - value_title_font_size/2
				MakeDetailsLine(details_root, details_x, details_y - 2, .5, "quagmire_recipe_line_short.tex")
				details_y = details_y - 8
				details_y = details_y - value_body_font_size/2
				local effects = details_root:AddChild(Text(HEADERFONT, value_body_font_size, ""))
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
        local desc = details_root:AddChild(Text(NUMBERFONT, title_font_size, item_data:GetDesc()))
        local desc_w, desc_h = desc:GetRegionSize()
        desc:SetPosition(0, y-8-desc_h/2)
        desc:SetColour(unpack(BROWN_DARK))

        y = y - 8
		y = y - body_font_size/2

		y = y - body_font_size/2 - 4
		y = row_start_y
		-- Perish Rate
		y = y - title_font_size/2

		y = y - title_font_size/2
		
        y = y - 8
		y = y - body_font_size/2
		
        y = y - body_font_size/2 - 4
		y = y - 10
        local ingds = item_data:GetIngds()
		-- if data.recipes ~= nil and #data.recipes > 0 then
        if ingds and #ingds>0 then
			-- Cooking Time
			y = y - title_font_size/2

			y = y - title_font_size/2
			
            y = y - 8
			y = y - body_font_size/2 - 4
			
            y = y - body_font_size/2 - 4
			y = y - 10
			-- INGREDIENTS
			y = y - title_font_size/2
   
            local str = "需要"
            title = details_root:AddChild(Text(HEADERFONT, title_font_size, str))
            title:SetColour(unpack(BROWN_DARK))
            title:SetPosition(0, y)
			y = y - title_font_size/2
			MakeDetailsLine(details_root, 0, y - 2, .49)
			y = y - 10
			self:SetIngredient(ingds, y)
		else
			y = y - title_font_size/2
			-- title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.COOKBOOK.NO_RECIPES_TITLE, BROWN_DARK))
            local str = "需要"
            title = details_root:AddChild(Text(HEADERFONT, title_font_size, str))
            title:SetColour(unpack(BROWN_DARK))
            title:SetPosition(0, y)
			y = y - title_font_size/2
			MakeDetailsLine(details_root, 0, y - 2, .49)
			y = y - 10
			y = y - body_font_size/2

        end

    y = y - 60
    local desc = details_root:AddChild(Text(HEADERFONT, 25, "再次点击进行加点,按下CTRL\n时点击可返还未确认的加点"))
    desc:SetColour(unpack(BROWN_DARK))
    desc:SetPosition(0, y, 0)

    self.details_root:AddChild(details_root)
end

local ExhibitionbookWidget = Class(Widget, function(self, data, owner)
    self.owner = owner
    self.data = data
    Widget._ctor(self, "ExhibitionbookWidget")
    self.root = self:AddChild(Widget("root"))
	
    self.tabs = {}
    self:Init()
end)

function ExhibitionbookWidget:Init()
    self:SetTabs()
    self.backdrop = self.root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_menu_bg.tex"))
    self.backdrop:ScaleToSize(900, 550)
    self.panel = self.root:AddChild(ExhibitionbookPage(self.data, self.owner))
end

function ExhibitionbookWidget:SetTabs()
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
		return tab
    end

    local shelf = self.data
    -- for k, v in pairs(shelf) do
        table.insert(self.tabs, self.root:AddChild(make_tab(shelf)))
    -- end
    -- 设置位置
    local len = #self.tabs
    local offset = #self.tabs / 2
    for i = 1, #self.tabs do
        local x = (i - offset - 0.5) * 200
        self.tabs[i]:SetPosition(x, 285)
    end
    -- 在此升级
    if self.tabs[1] then
        self.tabs[1]:SetOnClick(function()
            self.data:Sure(self.owner)
            self.master:Exit()
        end)
    end
end

local TpLevelBook = Class(Screen, function(self, data, owner)
    Screen._ctor(self, "TpLevelBook")
    self.data = data
    self.owner = owner

    Screen._ctor(self, "TpLevelBook")

    SetPause(true)
    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black.image:SetVRegPoint(ANCHOR_MIDDLE)
    black.image:SetHRegPoint(ANCHOR_MIDDLE)
    black.image:SetVAnchor(ANCHOR_MIDDLE)
    black.image:SetHAnchor(ANCHOR_MIDDLE)
    black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    black.image:SetTint(0,0,0,.5)
    black:SetOnClick(function() 
        self:Exit()
    end)
    -- black:SetHelpTextMessage("")

	local root = self:AddChild(Widget("root"))
	root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetVAnchor(ANCHOR_MIDDLE)
	root:SetPosition(0, -25)

    self.book = root:AddChild(ExhibitionbookWidget(data, owner))
    self.book.master = self
end)

function TpLevelBook:Exit()
    SetPause(false)
    TheFrontEnd:PopScreen() 
    self.data:OnExit(self.owner)
end

return TpLevelBook
