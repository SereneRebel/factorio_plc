local FOLDER = "__SignalController__"

data:extend({
	{
		type = "recipe",
		name = "plc-unit",
		enabled = false,
		energy_required = 20,
		ingredients = {
			{ "constant-combinator", 24 },
			{ "arithmetic-combinator", 32 },
			{ "decider-combinator", 32 },
			{ "electronic-circuit", 48 }
		},
		result = "plc-unit"
	},
	{
		type = "recipe-category",
		name = "plc-unit",
	},
	{
		type = "recipe",
		name = "plc-unit-power",
		hidden = true,
		ingredients = {},
		results = { { name = "plc-unit", amount = 0, probability = 0 } },
		main_product = "plc-unit",
		category = "plc-unit",
		icon = FOLDER .. "/graphics/blank.png",
		icon_size = 32,
	},
})
