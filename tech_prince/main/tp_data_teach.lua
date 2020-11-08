local words = {
}

local data = {
	{
		"进入游戏后建议在搜索世界里检查以下世界资源",
		"除了月之领主和天启骑士以外，第一页的资源应当都为1",
		"前期探查地图时可以做一个探测杖来探测战争熔炉和生命古树",
		"获得生命精华之后可以点开左上角的《提升等级》进行升级",
		"点击对应的属性便可提升对应的属性，每次点击会消耗一个生命精华",
		"加点完毕后点击确认即可升级，点击取消则返还生命精华",
		"点击《合成图鉴》可以查看不同工作台可以合成的物品",
		"点击这些物品可以显示相关信息和合成配方",
		"注意，一个工作台的合成配方不能适用于另一个工作台",
		"用错误的配方进行合成只能得到灰烬",
	},
	{
		"关于：诅咒值在平时会不断的下降，面对一些特殊的敌人时",
		"它们会提高玩家的诅咒值，当诅咒值达到上限时，玩家会直接死亡",
		"",
		"破甲：受到破甲debuff期间，所有装备的护甲收益减半",
		"流血：受到流血debuff期间，生命值会不断下降",
		"重伤：受到重伤debuff期间，所有生命回复效果减半",
	},
}

local function SentenceClass()
	local a_class = {
		sentences = {},
		add_page = function(t)
			-- t.sentences[#t.sentences+1] = {}
			table.insert(t.sentences, {})
		end,
		add_sentence = function(t, sentence)
			local n = #t.sentences[#t.sentences]
			if n >= 13 then
				t:add_page()
			end
			table.insert(t.sentences[#t.sentences], sentence)
		end,
		get_max_page = function(t)
			return #t.sentences
		end,
		get_sentences = function(t, page)
			return t.sentences[page]
		end,
	}
	return a_class
end

local sentence_manager = SentenceClass()
for k, v in pairs(data) do
	sentence_manager:add_page()
	for k2, v2 in pairs(v) do
		sentence_manager:add_sentence(v2)
	end
end
for k, v in pairs(words) do
	sentence_manager:add_sentence(v)
end

local function TeachPanelDataClass()
	local a_class = {
		title = "帮助信息",
		cur_page = 1,
		max_page = 1,
		sentence_manager = SentenceClass(),
		get_sentence = function(t)
			local sentences = sentence_manager:get_sentences(t.cur_page)
			local sentence = ""
			for k,v in pairs(sentences) do
				sentence = sentence..v.."\n"
				-- if k <= #sentences then
				-- 	sentence = sentence.."\n"
				-- end
			end
			return sentence
		end,
		get_title = function(t)
			return t.title
		end,
		page_turn = function(t, dt)
			t.cur_page = math.min(t.max_page, math.max(1, t.cur_page+dt))
		end,
	}
	return a_class
end

local teach_panel_data = TeachPanelDataClass()
teach_panel_data.sentence_manager = sentence_manager
teach_panel_data.max_page = sentence_manager:get_max_page()
GLOBAL.WARGON.DATA.teach_panel_data = teach_panel_data