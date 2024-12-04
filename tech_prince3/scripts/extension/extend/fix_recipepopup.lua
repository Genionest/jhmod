-- 修复不能使用mod图片资源做合成材料
AddClassPostConstruct('widgets/recipepopup', function(self)
	if self.recipepopup_fix then return end self.recipepopup_fix = true
	local old_refresh = self.Refresh
	function self:Refresh()
		old_refresh(self)
		if self.recipe then
			for k, v in pairs(self.recipe.ingredients) do
				if v.fix_image then
                    local atlas, image = v.atlas, v.fix_image
					-- print(atlas, image)
					local ing = self.ing[k]
					ing.ing:SetTexture(atlas, image)
				end
			end
		end
	end
end)

-- 修复不能使用mod图片作为额外栏里的制作栏的图标
AddClassPostConstruct("widgets/crafttabs", function(self)
	if self.recipepopup_fix then return end self.recipepopup_fix = true
    self.HandleMultiCraftingStationTabs = function(self,valid_tabs)
		-- if there's more than one tab at an index replace it with a multitab that has all these tabs
		local tabcounts = {}
		local multitab 
		for i,v in pairs(self.tabbyfilter) do
			if v ~= self.multitab then
				local isValid = valid_tabs[v]
				if isValid then
					local index = i.sort
					tabcounts[index] = tabcounts[index] or {}
					table.insert(tabcounts[index],{i,v})
				end
			end
		end

		-- do we have to create the multitab?
		for i,v in pairs(tabcounts) do
			if #v > 1 then
				-- show the multitab, hide the subtabs	
				if self.multitab then

					-- hide the specific subtabs
					for i,v in pairs(v) do   
						valid_tabs[v[2]] = false
					end
					-- show the multitab
					valid_tabs[self.multitab] = true

					-- and add them to the multitab
					self.multitab_crafting_stations = {}

					-- sort these guys, recipes are shown in the order they're added (or re-added)
					table.sort(v, function(a, b) 
										local tabname_a = a[1].str
										local tabname_b = b[1].str
										local tabdef_a = RECIPETABS[tabname_a]
										local tabdef_b = RECIPETABS[tabname_b]
										return tabdef_a.priority < tabdef_b.priority 
									end)
					
					local highlighted = false
					local alternatehighlighted = false
					local overlayshow = false

					for i,v in pairs(v) do
						-- Create RecipeCategories for these guys, and add tehm to the multitab
						local tabdef = v[1]
						local actualTab = v[2]

						local name = tabdef.str
						local tabname = name
						local imagename = actualTab.icon
						-- strip off the .tex if it exists
						if imagename:endsWith(".tex") then
							imagename = imagename:left(-4)
						end
						local tooltip = STRINGS.TABS[string.upper(name)]
						local category = RecipeCategory(tabname, RECIPETABS[name], RECIPETABS.CRAFTINGSTATIONS, TECH.NONE, RECIPE_GAME_TYPE.COMMON, imagename, tooltip)
						-- 就是这一句话
						category.atlas = actualTab.icon_atlas or actualTab.atlas
						category.imageScale = 0.5
						category.imageNudge = -6
						category.skipCategoryCheck = true -- to prevent some expensive work that is not needed on these guys

						self.multitab_crafting_stations[tabname] = true
						-- does this one have an alt-highlight?
						category.alternatehighlighted = actualTab.alternatehighlighted
						alternatehighlighted = alternatehighlighted or actualTab.alternatehighlighted
						-- or a highlight? (takes precedence)
						category.highlighted = actualTab.highlighted
						highlighted = highlighted or actualTab.highlighted
						-- an overlay?
						category.overlayshow = actualTab.overlayshow
						overlayshow = overlayshow or actualTab.overlayshow
					end
					-- handle ourselves as well
					if highlighted or alternatehighlighted then
						if highlighted then
							self.multitab:Highlight(1)
						else
							self.multitab:UnHighlight(true)
							self.multitab:AlternateHighlight(1)
						end
					else
						self.multitab:UnHighlight()
					end
					if overlayshow then
						self.multitab:Overlay()
					else
						self.multitab:HideOverlay()
					end
					-- force a refresh of the known recipes
					local recipes = GetAllRecipes(true)
				end
			end
		end
		
			--self.tabbyfilter[v] = tab
	end
end)