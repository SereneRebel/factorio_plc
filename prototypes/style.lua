local default_gui = data.raw["gui-style"].default

local icon_list = {
  {name="arrow_down"},
  {name="arrow_right"},
  {name="arrow_top"},
  {name="arrow_left"},
  {name="download"},
  {name="upload"},
  {name="refresh"},
  {name="clock"},
  {name="close"},
  {name="copy"},
  {name="help"},
  {name="info"},
  {name="maximize"},
  {name="minimize"},
  {name="menu"},
  {name="past"},
  {name="pin"},
  {name="delete"},
  {name="edit"},
  {name="settings"},
  {name="time"},
  {name="blank"}
}
local size_list = {
	{ suffix = "_sm",  icon_size = 16, icon_padding = 1 },
	{ suffix = "_m",   icon_size = 24, icon_padding = 1 },
	{ suffix = "",     icon_size = 32, icon_padding = 2 },
	{ suffix = "_xxl", icon_size = 64, icon_padding = 2 },
}
function monolithIcon(filename, size, scale, shift, position, border, stretch)
  return {
    type = "monolith",
    top_monolith_border = border.top,
    right_monolith_border = border.right,
    bottom_monolith_border = border.bottom,
    left_monolith_border = border.left,
    monolith_image = sprite(filename, size, scale, shift, position),
    stretch_monolith_image_to_size = stretch
  }
end
function sprite(filename, size, scale, shift, position)
  return {
    filename = filename,
    priority = "extra-high-no-scale",
    align = "center",
    width = size,
    height = size,
    scale = scale,
    shift = shift,
    x = position.x,
    y = position.y
  }
end
for _, size in pairs(size_list) do
	for icon_row, icon in pairs(icon_list) do
		local button_style = "plc_iconbutton_"..icon.name..size.suffix
		local button_sel_style = "plc_iconbutton_"..icon.name..size.suffix.."_selected"
		default_gui[button_style] = {
			type = "button_style",
			width = size.icon_size + 2 * size.icon_padding,
			height = size.icon_size + 2 * size.icon_padding,
			top_padding = size.icon_padding,
			right_padding = size.icon_padding,
			bottom_padding = size.icon_padding,
			left_padding = size.icon_padding,
			default_graphical_set = monolithIcon("__plc__/graphics/icons/menu_icons.png", 32, 1, {0,0}, {x=0,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true),
			hovered_graphical_set = monolithIcon("__plc__/graphics/icons/menu_icons.png", 32, 1, {0,0}, {x=32,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true),
			clicked_graphical_set = monolithIcon("__plc__/graphics/icons/menu_icons.png", 32, 1, {0,0}, {x=96,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true),
			disabled_graphical_set = monolithIcon("__plc__/graphics/icons/menu_icons.png", 32, 1, {0,0}, {x=64,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true)
		}
		default_gui[button_sel_style] = {
			type = "button_style",
			width = size.icon_size + 2 * size.icon_padding,
			height = size.icon_size + 2 * size.icon_padding,
			top_padding = size.icon_padding,
			right_padding = size.icon_padding,
			bottom_padding = size.icon_padding,
			left_padding = size.icon_padding,
			default_graphical_set = monolithIcon("__plc__/graphics/icons/menu_icons.png", 32, 1, {0,0}, {x=128,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true),
			hovered_graphical_set = monolithIcon("__plc__/graphics/icons/menu_icons.png", 32, 1, {0,0}, {x=32,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true),
			clicked_graphical_set = monolithIcon("__plc__/graphics/icons/menu_icons.png", 32, 1, {0,0}, {x=96,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true),
			disabled_graphical_set = monolithIcon("__plc__/graphics/icons/menu_icons.png", 32, 1, {0,0}, {x=64,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true)
		}
	end
end

default_gui["plc_button_tab"] = {
  type = "button_style",
  font = "plc_font_normal",
  default_font_color={r=1, g=1, b=1},
  align = "center",
  top_padding = 2,
  right_padding = 8,
  bottom_padding = 2,
  left_padding = 8,
  height = 28,
  default_graphical_set = {type = "composition",filename = "__plc__/graphics/gui.png",priority = "extra-high-no-scale",corner_size = {3,3},position = {16, 0}},
  hovered_font_color={r=0, g=0, b=0},
  hovered_graphical_set = {type = "composition",filename = "__plc__/graphics/gui.png",priority = "extra-high-no-scale",corner_size = {3,3},position = {16, 8}},
  clicked_font_color={r=1, g=1, b=1},
  clicked_graphical_set = {type = "composition",filename = "__plc__/graphics/gui.png",priority = "extra-high-no-scale",corner_size = {3,3},position = {16, 0}},
  disabled_font_color={r=0.5, g=0.5, b=0.5},
  disabled_graphical_set = {type = "composition",filename = "__plc__/graphics/gui.png",priority = "extra-high-no-scale",corner_size = {3,3},position = {16, 0}},
  pie_progress_color = {r=1, g=1, b=1}
}

default_gui["plc_button_tab_selected"] = {
  type = "button_style",
  font = "plc_font_normal",
  default_font_color={r=1, g=1, b=1},
  align = "center",
  top_padding = 2,
  right_padding = 8,
  bottom_padding = 2,
  left_padding = 8,
  height = 28,
  default_graphical_set = {type = "composition",filename = "__plc__/graphics/gui.png",priority = "extra-high-no-scale",corner_size = {3,3},position = {8, 0}},
  hovered_font_color={r=0, g=0, b=0},
  hovered_graphical_set = {type = "composition",filename = "__plc__/graphics/gui.png",priority = "extra-high-no-scale",corner_size = {3,3},position = {8, 8}},
  clicked_font_color={r=1, g=1, b=1},
  clicked_graphical_set = {type = "composition",filename = "__plc__/graphics/gui.png",priority = "extra-high-no-scale",corner_size = {3,3},position = {8, 0}},
  disabled_font_color={r=0.5, g=0.5, b=0.5},
  disabled_graphical_set = {type = "composition",filename = "__plc__/graphics/gui.png",priority = "extra-high-no-scale",corner_size = {3,3},position = {8, 0}},
  pie_progress_color = {r=1, g=1, b=1}
}

default_gui["plc_label_default"] = {
  type = "label_style",
  parent = "label",
  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2,
	font = "plc_font_big"
}
default_gui["plc_label_help_number"] = {
  type = "label_style",
  parent = "plc_label_default",
  left_padding = 10,
  align = "right",
  minimal_width = 30
}
default_gui["plc_label_help_text"] = {
  type = "label_style",
  parent = "plc_label_default",
  left_padding = 10,
  minimal_width = 350,
  --maximal_width = 350,
  vertical_align = "top",

}

default_gui["plc_table_list"] = {
  type = "table_style",
  horizontal_spacing = 1,
  vertical_spacing = 1,
  cell_spacing = 1,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  vertical_align = "top"
}
default_gui["plc_table_tab"] = {
  type = "table_style",
  horizontal_spacing = 0,
  vertical_spacing = 0,
  cell_spacing = 0,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  vertical_align = "top"
}

default_gui["plc_menu_tab"] = {
	type = "button_style",
	parent = "plc_button_tab",
	font = "plc_font_big"
}
default_gui["plc_menu_tab_selected"] = {
	type = "button_style",
	parent = "plc_button_tab_selected",
	font = "plc_font_big"
}

default_gui["plc_table_alernating"] = {
  type = "table_style",
  -- default orange with alfa
  hovered_row_color = {r=0.98, g=0.66, b=0.22, a=0.7},
  cell_padding = 1,
  vertical_align = "center",
  horizontal_spacing = 3,
  vertical_spacing = 2,
  horizontal_padding = 1,
  vertical_padding = 1,
  even_row_graphical_set =
  {
    type = "composition",
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    corner_size = {0, 0},
    position = {78, 18},
    opacity = 0.7
  }
}
default_gui["plc_textfield"] = {
  type = "textfield_style",
  parent = "textfield",
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

default_gui["plc_textbox_default"] = {
	type = "textbox_style",
	parent = "textbox",
	font = "plc_font_big",
	minimal_width = 500,
	maximal_width = 500,
	minimal_height = 100,
	maximal_height = 500,
	width = 500,
	height = 100,
	vertical_scrollbar_policy = "never",
	
}
default_gui["plc_frame_hidden"] = {
  type = "frame_style",
  font_color = {r=1, g=1, b=1},
  -- marge interieure
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,

  -- padding title
  title_top_padding = 0,
  title_left_padding = 0,
  title_bottom_padding = 4,
  title_right_padding = 0,

  font = "plc_font_title_frame",

  
  flow_style = {
    type = "flow_style",
    horizontal_spacing = 0,
    vertical_spacing = 0
  },
  horizontal_flow_style =
  {
    type = "horizontal_flow_style",
    horizontal_spacing = 0,
  },

  vertical_flow_style =
  {
    type = "vertical_flow_style",
    vertical_spacing = 0
  },
  graphical_set =
  {
    type = "composition",
    filename = "__plc__/graphics/gui.png",
    priority = "extra-high-no-scale",
    load_in_minimal_mode = true,
    corner_size = {0, 0},
    position = {0, 0}
  }
}
default_gui["plc_frame_param"] = {
  type = "frame_style",
  parent = "plc_frame_hidden",
	font = "plc_font_big",
  minimal_width = 120,
  maximal_width = 120
}
default_gui["plc_frame_save_left"] = {
	type = "frame_style",
	parent = "plc_frame_hidden",
	minimal_width = 310,
	maximal_width = 310,
	minimal_height = 200,
	maximal_height = 200
}
default_gui["plc_frame_save_right"] = {
	type = "frame_style",
	parent = "plc_frame_hidden",
	minimal_width = 200,
	maximal_width = 200,
	minimal_height = 200,
	maximal_height = 200
}

default_gui["plc_main_panel"] = {
	type = "frame_style",
	parent = "plc_frame_hidden",
	minimal_width = 700,
	maximal_width = 700,
	minimal_height = 650,
	maximal_height = 650,
	width = 700,
	height = 650
}

default_gui["plc_frame_default"] = {
  type = "frame_style",
  font = "plc_font_title_frame",
  font_color = {r=1, g=1, b=1},
  -- marge interieure
  top_padding  = 0,
  right_padding = 2,
  bottom_padding = 0,
  left_padding = 2,

  -- padding title
  title_top_padding = 0,
  title_left_padding = 0,
  title_bottom_padding = 4,
  title_right_padding = 0,
  graphical_set = {
    type = "composition",
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    load_in_minimal_mode = true,
    corner_size = {3, 3},
    position = {8, 0}
  },
  flow_style = {
    type = "flow_style",
    horizontal_spacing = 0,
    vertical_spacing = 0
  },
  horizontal_flow_style =
  {
    type = "horizontal_flow_style",
    horizontal_spacing = 0,
  },

  vertical_flow_style =
  {
    type = "vertical_flow_style",
    vertical_spacing = 0
  }
}
default_gui["plc_frame_hidden_fill"] = {
  type = "frame_style",
  parent = "plc_frame_hidden",
  horizontally_stretchable = "on",
  vertically_stretchable = "on",
}
default_gui["plc_frame_default_fill"] = {
  type = "frame_style",
  parent = "plc_frame_default",
  horizontally_stretchable = "on",
  vertically_stretchable = "on",
}
default_gui["plc_program_pane"] = {
  type = "scroll_pane_style",
  parent = "scroll_pane",
  minimal_height = 550,
  horizontally_stretchable = "on",
  vertically_stretchable = "on",
}
default_gui["plc_frame_section"] = {
  type = "frame_style",
  parent = "plc_frame_default",
  graphical_set = {type = "composition",filename = "__plc__/graphics/gui.png", priority = "extra-high-no-scale", corner_size = {0,0}, position = {0, 0}},
}

default_gui["plc_frame_tab"] = {
  type = "frame_style",
  parent = "frame",
  -- marge interieure
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,

  -- padding title
  title_top_padding = 0,
  title_left_padding = 0,
  title_bottom_padding = 0,
  title_right_padding = 0,
  graphical_set = {type = "composition",filename = "__plc__/graphics/gui.png",priority = "extra-high-no-scale",corner_size = {3, 3},position = {24, 0}}
}

default_gui["plc_final_tab"] = {
  type = "frame_style",
  parent = "frame",
  -- marge interieure
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,

  -- padding title
  title_top_padding = 0,
  title_left_padding = 0,
  title_bottom_padding = 0,
  title_right_padding = 0,
  graphical_set = {type = "composition",filename = "__plc__/graphics/gui.png",priority = "extra-high-no-scale",corner_size = {3, 3},position = {24, 0}},
  width = 500,
  horizontally_squashable = "on"
}


default_gui["plc_loadsave_pane"] = {
  type = "scroll_pane_style",
  parent = "scroll_pane",
  minimal_height = 105,
  maximal_height = 105,
  vertical_scrollbar_policy = "auto-and-reserve-space",
}
