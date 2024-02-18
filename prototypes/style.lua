local default_gui = data.raw["gui-style"].default

default_gui["plc_main_frame"] =
{
  type = "frame_style",
  parent = "frame",
  size = { 850, 650 },
}

default_gui["plc_textfield"] = {
	type = "textbox_style",
	parent = "textbox",
	font = "plc_font_big",
	minimal_width = 100,
	maximal_width = 100
}

default_gui["plc_dropdown"] = {
	type = "dropdown_style",
	parent = "dropdown",
	font = "plc_font_big",
	minimal_width = 100,
	maximal_width = 100
}

default_gui["plc-unit-scroll"] = {
	type = "scroll_pane_style",
	padding = 2,
	minimal_height = 44,
	extra_padding_when_activated = 0,
	horizontally_stretchable = "off",
	background_graphical_set = {
		corner_size = 1,
		position = { 41, 7 },
	},
}

default_gui["plc-unit-slot"] = {
	type = "button_style",
	parent = "slot_button_in_shallow_frame",
	font = "default-game",
	default_font_color = { 1, 1, 1 },
	hovered_font_color = { 1, 1, 1 },
	clicked_font_color = { 1, 1, 1 },
	horizontal_align = "center",
	minimal_width = 40,
	natural_width = 40,
	maximal_width = 80,
	draw_shadow_under_picture = false,
}

