local function get_config(key)
    return GLOBAL.WARGON.get_config(key)
end

GLOBAL.WARGON.CONFIG = {
    lan     = get_config("language"),
    diff    = get_config("difficulty"),
    fast	= get_config("fast"),
}