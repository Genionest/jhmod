local function hat_on(owner, build, file)
	local f = file or "swap_hat"
	owner.AnimState:OverrideSymbol("swap_hat", build, f)
	owner.AnimState:Show("HAT")
	owner.AnimState:Show("HAIR_HAT")
	owner.AnimState:Hide("HAIR_NOHAT")
	owner.AnimState:Hide("HAIR")
	if owner:HasTag("player") then
		owner.AnimState:Hide("HEAD")
		owner.AnimState:Show("HEAD_HAIR")
		owner.AnimState:Hide("HAIRFRONT")
	end
end

local function hat_open(owner, build, file)
	local f = file or "swap_hat"
	owner.AnimState:OverrideSymbol("swap_hat", build, f)
	owner.AnimState:Show("HAT")
	owner.AnimState:Hide("HAIR_HAT")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")
	owner.AnimState:Show("HAIRFRONT")

	owner.AnimState:Show("HEAD")
	owner.AnimState:Hide("HEAD_HAIR")
end

local function hat_off(owner)
	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAIR_HAT")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")

	if owner:HasTag("player") then
		owner.AnimState:Show("HEAD")
		owner.AnimState:Hide("HEAD_HAIR")
		owner.AnimState:Show("HAIRFRONT")
	end
end

local function body_on(owner, build, file)
	local f = file or "swap_body"
	owner.AnimState:OverrideSymbol("swap_body", build, f)
end

local function body_off(owner)
	owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function object_on(owner, build, file)
	local f = file or build
	owner.AnimState:OverrideSymbol("swap_object", build, f)
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function object_off(owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

GLOBAL.WARGON_EQUIP_EX = {
	hat_on 		= hat_on,
	hat_open 	= hat_open,
	hat_off		= hat_off,
	body_on		= body_on,
	body_off	= body_off,
	object_on	= object_on,
	object_off	= object_off,
}

GLOBAL.WARGON.EQUIP = GLOBAL.WARGON_EQUIP_EX