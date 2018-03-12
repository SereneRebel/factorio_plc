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
		name = "plc-power",
	},
	{
		type = "recipe",
		name = "plc-power",
		enabled = false,
		hidden = true,
		ingredients = {},
		results = { { name = "plc-power", amount = 0, probability = 0 } },
		main_product = "plc-power",
		category = "plc-power",
	},
})
