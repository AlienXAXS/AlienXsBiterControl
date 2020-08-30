data:extend({
    {
        type = "bool-setting",
        name = "cbc-enabled",
        setting_type = "runtime-global",
        default_value = true,
		order = "a"
    },
	{
        type = "bool-setting",
        name = "cbc-biters-disable",
        setting_type = "runtime-global",
        default_value = true,
		order = "b"
    },
	{
        type = "bool-setting",
        name = "cbc-biters-force-disable",
        setting_type = "runtime-global",
        default_value = false,
		order = "ba"
    },
	{
        type = "double-setting",
        name = "cbc-game-speed",
		minimum_value = 0.1,
		maxiumum_value = 1,
        setting_type = "runtime-global",
        default_value = 0.25,
		order = "d"
    },
})