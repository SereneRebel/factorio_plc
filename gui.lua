require("util")

--#######################
--#                     #
--#    GUI Utilities    #
--#                     #
--#######################
function addGuiFrameH(container, parent, key, style, caption)
	container = container or {}
	if not container or not container.valid then
		container = parent.add({type = "frame", direction="horizontal", name = key})
	end
	container.caption = caption or container.caption
	container.style = style or container.style
	return container
end

function addGuiFrameV(container, parent, key, style, caption)
	container = container or {}
	if not container or not container.valid then
		container = parent.add({type = "frame", direction="vertical", name = key})
	end
	container.caption = caption or container.caption
	container.style = style or container.style
	return container
end

function addGuiLabel(container, parent, key, caption, style, tooltip, single_line)
	container = container or {}
	if not container or not container.valid then
		container = parent.add({type = "label", name = key})
	end
	if tooltip ~= nil then container.tooltip = tooltip end
	if single_line ~= nil then container.style.single_line = single_line end
	if caption ~= nil then container.caption = caption end
	if style ~= nil then container.style = style end
	return container
end

function addGuiTextfield(container, parent, key, text, style, tooltip)
	container = container or {}
	if not container or not container.valid then 
		container = parent.add({type = "textfield",name = key,})
	end
	if style ~= nil then
		container.style = style
	end
	if tooltip ~= nil then
		container.tooltip = tooltip
	end
	container.style = style
	container.text = text or ""
	return container
end

function addGuiTextbox(container, parent, key, text, style, tooltip)
	container = container or {}
	if not container or not container.valid then 
		container = parent.add({type = "text-box",name = key})
	end
	if style ~= nil then
		container.style = style
	end
	if tooltip ~= nil then
		container.tooltip = tooltip
	end
	container.text = text or ""
	container.style = style
	return container
end

function addCellHeader(container, guiTable, name, caption)
	container = container or {}
	container.cell = addGuiFrameH(container.cell, guiTable,"header-"..name, "plc_frame_hidden")
    container.label = addGuiLabel(container.label, container.cell, "label", caption)
end

function addCell(container, parent, name, column_count)
	return addGuiTable(container, parent, "cell_"..name, column_count or 3, "plc_table_list")
end

function addGuiTable(container, parent, key, column_count, style)
	container = container or {}
	if not container or not container.valid then
		container = parent.add({type = "table", column_count = column_count, name = key})
	end
	if style ~= nil then
		container.style = style
	end
	return container
end

function addGuiButton(container, parent, action, key, style, caption, tooltip)
	container = container or {}
	if key ~= nil then action = action..key end
	if not container or not container.valid then
		container = parent.add({type = "button", name = action})
	end
	if style ~= nil then container.style = style end
	if caption ~= nil then container.caption = caption end
	if tooltip ~= nil then container.tooltip = tooltip end
	return container
end

function addGuiSignalButton(container, parent, action, key, style, signal, tooltip)
	container = container or {}
	if key ~= nil then action = action..key end
	if not container or not container.valid then
		container = parent.add({type = "choose-elem-button", name = action, elem_type="signal"})
	end
	if signal ~= nil then container.elem_value = signal end
	if style ~= nil then container.style = style end
	if tooltip ~= nil then container.tooltip = tooltip end
	return container
end

function addMenuTab(container, parent, name, selected, tooltip)
	local style = (selected) and "plc_menu_tab_selected" or "plc_menu_tab"
	container = container or {}
	container.separator = addGuiFrameH(container.separator, parent, name.."TabSeparator","plc_frame_tab")
	container.separator.style.width = 5
	container.tab = addGuiButton(container.tab, parent, "plc_menu_", name, style, {"plc_menu.tab_"..name}, tooltip)
	return container
end

function addGuiScrollPane(container, parent, key, style)
	container = container or {}
	if not container or not container.valid then
		container = parent.add({type = "scroll-pane", horizontal_scroll_policy = "auto", vertical_scroll_policy = "auto", horizontally_stretchable = true, name = key, style = style})
	end
	return container
end


function addGuiDropDown(container, parent, name, list, selIndex, style, tooltip)
	container = container or {}
	selIndex = selIndex or 1
	if not container or not container.valid then 
		container = parent.add({type = "drop-down", name = name})
	end
	container.style = style or container.style
	container.tooltip = tooltip or container.tooltip
	container.items = list
	container.selected_index = selIndex
	return container
end

