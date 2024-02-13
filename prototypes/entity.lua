local FOLDER = "__SignalController__"
local img_blank = {
	filename = FOLDER .. "/graphics/blank.png",
	priority = "extra-high",
	width = 1,
	height = 1,
	frame_count = 1,
	shift = { 0, 0 },
}
local img_led_output = {
	filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
	width = 32,
	height = 6,
	frame_count = 1,
	shift = { -0.32, 0.20625 },
}
local img_led_input = {
	filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
	width = 32,
	height = 6,
	frame_count = 1,
	shift = { 0.296875, -0.40625 },
}
local con_point_output = {
	shadow = {
		red = { -0.05, -0.4 },
		green = { -0.05, -0.2 },
	},
	wire = {
		red = { -0.05, -0.35 },
		green = { -0.05, -0.15 },
	}
}
local con_point_input = {
	shadow = {
		red = { 0.05, -0.4 },
		green = { 0.05, -0.2 },
	},
	wire = {
		red = { 0.05, -0.35 },
		green = { 0.05, -0.15 },
	}
}

---comment
---@param type string
---@return data.ConstantCombinatorPrototype|nil
function io_entity(type)
	if not type or type ~= "input" and type ~= "output" then
		return nil
	end
	local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
	entity.name = "plc-" .. type
	entity.icon = FOLDER .. "/graphics/icon/plc.png"
	table.insert(entity.flags, "placeable-off-grid")
	table.insert(entity.flags, "not-deconstructable")
	table.insert(entity.flags, "not-repairable")
	entity.minable = nil
	entity.operable = false
	entity.rotatable = false
	entity.collision_box = { { -0.0, -0.0 }, { 0.0, 0.0 } }
	entity.collision_mask = { "not-colliding-with-itself" }
	entity.selection_box = { { -0.4, -0.4 }, { 0.4, 0.4 } }
	entity.sprites = { north = img_blank, east = img_blank, south = img_blank, west = img_blank }
	entity.activity_led_light = { intensity = 0.8, size = 1, }
	entity.activity_led_light_offsets = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }
	entity.circuit_wire_max_distance = 10
	if type == "output" then
		entity.item_slot_count = 1000
		entity.circuit_wire_connection_points = { con_point_output, con_point_output, con_point_output, con_point_output }
	else
		entity.circuit_wire_connection_points = { con_point_input, con_point_input, con_point_input, con_point_input }
		entity.item_slot_count = 0
		entity.activity_led_sprites = {
			north = img_led_input,
			east = img_led_input,
			south = img_led_input,
			west = img_led_input
		}
		entity.activity_led_sprites = {
			north = img_led_output,
			east = img_led_output,
			south = img_led_output,
			west = img_led_output
		}
	end
	return entity
end

---comment
---@return data.AssemblingMachinePrototype
function unit_entity()
	local entity = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
	entity.name = "plc-unit"
	entity.icon = FOLDER .. "/graphics/icon/plc.png"
	entity.minable = { mining_time = 2, result = "plc-unit" }
	entity.corpse = "big-remnants"
	entity.dying_explosion = "medium-explosion"
	entity.selection_box = { { -0.8, -1.4 }, { 0.8, 1.4 } }
	entity.inventory_size = 0
	entity.picture = {
		filename = FOLDER .. "/graphics/entity/plc.png",
		priority = "high",
		width = 250,
		height = 200,
		shift = { 0.34375, 0 },
	}
	entity.crafting_categories = { "plc-unit" }
	entity.fixed_recipe = "plc-unit-power"
	entity.crafting_speed = 1.0
	entity.energy_source = { type = "electric", usage_priority = "secondary-input", emissions_per_minute = 0 }
	entity.energy_usage = "120kW"
	entity.ingredient_count = 0
	entity.module_specification = {}
	entity.allowed_effects = {}
	entity.animation.layers = {{
		filename = FOLDER .. "/graphics/entity/plc.png",
		frame_count = 1,
		width = 250,
		height = 200,
		scale = 0.8,
		line_length = 8,
		priority = "high",
		shift = { 0.3, 0.45 },
	}}
	return entity
end

local input = io_entity("input")
local output = io_entity("output")
local unit = unit_entity()

if input ~= nil and output ~= nil and unit ~= nil then
	data:extend({ input, output, unit, })
end
