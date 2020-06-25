
local texture = resolvefilepath("fx/sparkle.tex")
-- local texture = resolvefilepath("images/wave.tex")
local shader = resolvefilepath("shaders/vfx_particle_add.ksh")
local COLOUR_ENVELOPE_NAME = "tp_sparkle_colourenvelope"
local SCALE_ENVELOPE_NAME = "tp_sparkle_scaleenvelope"
local assets =
{
	-- Asset( "IMAGE", texture ),
	-- Asset( "SHADER", shader ),
}

local function IntColour( r, g, b, a )
	return { r / 255.0, g / 255.0, b / 255.0, a / 255.0 }
end

local function InitEnvelope()
    local envs = {}
    local t = 0
    local step = .15
    while t + step + .01 < 1 do
        table.insert(envs, { t, IntColour(255, 255, 150, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 255, 150, 0) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(255, 255, 150, 0) })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, envs)

    local sparkle_max_scale = .4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale, sparkle_max_scale } },
            { 1,    { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end
local MAX_LIFETIME = 1.75

local function emit_sparkle_fn(emitter, sphere_emitter)
    local vx, vy, vz = .012 * UnitRand(), 0, .012 * UnitRand()
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()

    local angle = math.random() * 360    
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = (UnitRand() - 1) * 5
	emitter:AddRotatingParticleUV(
		lifetime,		
		px, py, pz,			
		vx, vy, vz,			
		angle,				
		ang_vel,			
		uv_offset, 0	
	)
end
local function fn(Sim)
	local inst = CreateEntity()
	inst:AddTag("FX")
	local trans = inst.entity:AddTransform()
	local emitter = inst.entity:AddParticleEmitter()
	inst:AddTag("INTERIOR_LIMBO_IMMUNE")
    if InitEnvelope ~= nil then
        InitEnvelope()
    end
    emitter:SetRenderResources(texture, shader)
    emitter:SetRotationStatus(true)
    emitter:SetUVFrameSize(.25, 1)
    emitter:SetMaxNumParticles(256)
    emitter:SetMaxLifetime(MAX_LIFETIME)
    emitter:SetColourEnvelope(COLOUR_ENVELOPE_NAME)
    emitter:SetScaleEnvelope(SCALE_ENVELOPE_NAME)
    emitter:SetBlendMode(BLENDMODE.Additive)
    emitter:EnableBloomPass(true)
    emitter:SetSortOrder(0)
    inst.persists = false
    
    local tick_time = TheSim:GetTickTime()

    local sparkle_desired_pps_low = 5
    local sparkle_desired_pps_high = 50
    local low_per_tick = sparkle_desired_pps_low * tick_time
    local high_per_tick = sparkle_desired_pps_high * tick_time
    local num_to_emit = 0

    local sphere_emitter = CreateSphereEmitter(.25)
    inst.last_pos = inst:GetPosition()
    EmitterManager:AddEmitter(inst, nil, function()
        local dist_moved = inst:GetPosition() - inst.last_pos
        local move = dist_moved:Length()
        move = math.clamp(move*6, 0, 1)
        local per_tick = Lerp(low_per_tick, high_per_tick, move)
        inst.last_pos = inst:GetPosition()   
        num_to_emit = num_to_emit + per_tick * math.random() * 3
        while num_to_emit > 1 do
            emit_sparkle_fn(emitter, sphere_emitter)
            num_to_emit = num_to_emit - 1
        end
    end)
    return inst
end
return Prefab( "tp_sparkle_fx", fn, assets) 
 
