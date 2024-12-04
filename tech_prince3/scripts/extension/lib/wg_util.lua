local Util = {}

--[[
给予一个元素，返回列表中的下一个元素，
如果给予的是最后一个元素，返回第一个元素
]]
function Util:NextElement(tbl, val)
    local next = nil
    for k, v in pairs(tbl) do
        if next then
            return v
        end
        if v == val then
            next = true
        end
    end
    -- 走到这一步代表最后一个val是tbl的最后一个元素
    if next then
        return tbl[1]
    end
    print("Util.NextElement: val not in tbl.")
end

--[[
获取目标位置  
(Vector3)/(number)x,(number)y,(number)z 返回对应的位置  
pt, (EntityScript/Vector3)需要获取位置的目标  
is_v, 为true则返回类型为Vector3，否则返回x,y,z  
]]
function Util:GetPos(pt, is_v)
    assert(type(pt)=="table", "arguments \"pt\" must be table.")
    if pt.Get then
		if is_v then
			return pt 
		else
			return pt:Get()
		end
    elseif pt.GetPosition then
		if is_v then
			return pt:GetPosition() 
		else
			return pt:GetPosition():Get()
		end
    else
        assert(nil, string.format("arguments \"pt\"(%s) is invalid.", tostring(pt)))
    end
end

--[[
消除字符串首部的换行符  
(string) 返回改动后的字符串  
str (string)需要修改的字符串  
]]
function Util:StringStrip(str)
    str = string.gsub(str, "^\n+", "")
    str = string.gsub(str, "\n+$", "")
    return str
end

--[[
切分字符串，若字符串超出限定长度（遇到换行符直接切分，
但不会将换行符包含进去），将其一分为二  
(string)sub_str, (string)other_str 返回这两个子字符串  
否则返回该字符串(origin_str)  
str 需要切分的字符串  
words_width 限定长度  
]]
function Util:SplitString(str, words_width)
    assert(type(str)=="string", "arguments must be string.")
    assert(type(words_width)=="number", "arguments must be number.")

    str = self:StringStrip(str)
    local len = #str
	local cnt = 0
	local wid = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		cnt = cnt + 1
		if byte > 127 then
			if cnt >= 3 then
				cnt = 0
				wid = wid + 2
			end
        elseif byte == 10 then
            -- cnt = 0
            -- wid = 0
            return string.sub(str, 1, i-1), string.sub(str, i+1, -1)
		else
			cnt = 0
			wid = wid + 1
		end
		if wid >= words_width * 2 then
			if i < len then
				return string.sub(str, 1, i), string.sub(str, i+1, -1)
			end
		end
	end
	return str
end

--[[
给定长度，将一个字符串变成多行，且每行不大于限定长度的字符串,
并将他们放入一个列表中，或者转换成多行字符串  
(table/string) 返回这个列表或者转换的字符串  
sentence (string)需要切分的字符串  
limit (number)限定长度，默认为15  
to_str (bool)是否返回字符形式  
]]
function Util:SplitSentence(sentence, limit, to_str)
	limit = limit or 15
    local t = {}
	local str, substr = self:SplitString(sentence, limit)
    table.insert(t, str)
    -- local sentence = str
	-- 循环分割直到不可分割
	while substr do
		str, substr = self:SplitString(substr, limit)
		-- sentence = sentence.."\n"..str
        -- str有可能是"",因为换行符会被删掉，如果末尾有\n，那么末尾就会变成空字符
        if #str>0 then
            table.insert(t, str)
        end
    end
	-- return sentence
    if to_str then
        local s = self:Table2String(t)
        return s
    else
        return t
    end
end

--[[
将字符串列表转换为多行的字符串  
(string) 多行字符串
tbl (table{string})字符串列表  
]]
function Util:Table2String(tbl)
    assert(#tbl>0, "argument \"tbl\" don't have element.")

    local s = tbl[1]
    for i = 2, #tbl do
        s = s.."\n"..tbl[i]
    end
    return s
end

--[[
添加描述  
prefab_name (string)预制物名  
name (string)名字翻译  
desc (string)描述翻译  
]]
function Util:AddString(prefab_name, name, desc)
    prefab_name = string.upper(prefab_name)
    STRINGS.NAMES[prefab_name] = name
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[prefab_name] = desc
end

--[[
获取对应prefab的名字翻译  
(string) 返回这个翻译  
prefab (string)预制物名  
]]
function Util:GetScreenName(prefab)
    local s = STRINGS.NAMES[string.upper(prefab)]
    if type(s) == "table" then
        for k, v in pairs(s) do
            s = v
            break
        end
    end
    return s or prefab
end

--[[
获取对应prefab的描述翻译  
(string) 返回这个翻译  
prefab (string)预制物名  
split (bool)是否切分描述  
]]
function Util:GetDescription(prefab, split)
    local s = STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper(prefab)]
    if type(s) == "table" then
        for k, v in pairs(s) do
            s = v
        end
    end
    if split and s then
        local t = self:SplitSentence(s, 15)
        s = t[1]
        for i = 2, #t do
            s = s.."\n"..t[i]
        end
    end
    return s or prefab
end

return Util