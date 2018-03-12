require("util")
require("structure")
require("gui")
require("program")
local initDone = false

local function onInit()
	if initDone then return end
	-- gui related globals
	global.gui = global.gui or {}
	global.gui.currentTab = global.gui.currentTab or "program"
	global.nextStructId = global.nextStructId or 1
	-- structure globals -- structures being the group of entities constituting the structure
	global.structures = global.structures or {}
	global.unitNumbers = global.unitNumbers or {}
	global.ghosts = global.ghosts or {}
	initDone = true
end

function programPage(gui, structure) 
	local cmdList = {}
	for ind, command in pairs(commandList) do
		cmdList[ind] = command.disp
	end


	-- page creation
	gui.data.runFrame = addGuiFrameH(gui.data.runFrame, gui.data.page,"runbuttonframe", "plc_frame_hidden")
	gui.data.runButton = addGuiButton(gui.data.runButton, gui.data.runFrame, "plc_prgm_run", "", structure.data.runMode and "plc_iconbutton_time_selected" or "plc_iconbutton_time", "", structure.data.runMode and {"plc_tooltip.run_button_running"} or {"plc_tooltip.run_button_stopped"})
	gui.data.runLabel = addGuiLabel(gui.data.runLabel, gui.data.runFrame, "label", structure.data.runMode and "Running" or "Stopped")
	
	gui.data.table = addGuiTable(gui.data.table, gui.data.page,"plcProgramTable", 5, "plc_table_alernating")
	
	gui.data.tableHeader = gui.data.tableHeader or {{},{},{},{},{}}
	local header1 = gui.data.tableHeader[1]
	header1.cell = addGuiFrameH(header1.cell, gui.data.table,"header-1", "plc_frame_hidden")
	header1.label = addGuiLabel(header1.label, header1.cell, "label", "Editing")
	local header2 = gui.data.tableHeader[2]
	header2.cell = addGuiFrameH(header2.cell, gui.data.table,"header-2", "plc_frame_hidden")
	header2.label = addGuiLabel(header2.label, header2.cell, "label", "Command")
	local header3 = gui.data.tableHeader[3]
	header3.cell = addGuiFrameH(header3.cell, gui.data.table,"header-3", "plc_frame_hidden")
	header3.label = addGuiLabel(header3.label, header3.cell, "label", "Parameter 1")
	local header4 = gui.data.tableHeader[4]
	header4.cell = addGuiFrameH(header4.cell, gui.data.table,"header-4", "plc_frame_hidden")
	header4.label = addGuiLabel(header4.label, header4.cell, "label", "Parameter 2")
	local header5 = gui.data.tableHeader[5]
	header5.cell = addGuiFrameH(header5.cell, gui.data.table,"header-5", "plc_frame_hidden")
	header5.label = addGuiLabel(header5.label, header5.cell, "label", "Parameter 3")
	-- get number of lines from structure
	local linecount = structure.program.programCount
	-- get the program data from structure
	local datalist = structure.program.program
	gui.data.code = gui.data.code or {}
	for line = 1, linecount do
		-- get the line or default it
		datalist[line] = datalist[line] or {cmd = 1, params = {}}
		local code = datalist[line]
		code.cmd = code.cmd or 1
		code.params = code.params or {}
		-- display the line
		gui.data.code[line] = gui.data.code[line] or {}
		local content = gui.data.code[line]
		content.acell = addCell(content.acell, gui.data.table, "action"..line, 3)
		content.del = addGuiButton(content.del, content.acell, "plc_prgm_delete_", line, "plc_iconbutton_delete", "", {"plc_tooltip.delete_line"})
		if line == 1 then
			content.up = addGuiButton(content.up, content.acell, "plc_prgm_moveup_", line, "plc_iconbutton_blank", "")
		else
			content.up = addGuiButton(content.up, content.acell, "plc_prgm_moveup_", line, "plc_iconbutton_arrow_top", "", {"plc_tooltip.move_line_up"})
		end
		if line == linecount then
			content.dn = addGuiButton(content.dn, content.acell, "plc_prgm_movedn_", line, "plc_iconbutton_blank", "")
		else
			content.dn = addGuiButton(content.dn, content.acell, "plc_prgm_movedn_", line, "plc_iconbutton_arrow_down", "", {"plc_tooltip.move_line_down"})
		end
		content.codeFrameCmd = addGuiFrameH(content.codeFrameCmd, gui.data.table,"codeCmd"..line, "plc_frame_param")
		content.codeCmd = addGuiDropDown(content.codeCmd, content.codeFrameCmd, "plc_code_cmd_"..line, cmdList, code.cmd, "plc_dropdown", {"plc_command_tooltip."..(cmdList[code.cmd or 1])})

		content.codeFrameParam1 = addGuiFrameH(content.codeFrameParam1, gui.data.table,"codeParam1"..line, "plc_frame_param")
		content.codeParam1 = addGuiTextfield(content.codeParam1, content.codeFrameParam1, "plc_code_param1_"..line, code.params and code.params[1] or "", "plc_textfield", {"plc_tooltip.parameter1"})
		content.codeFrameParam2 = addGuiFrameH(content.codeFrameParam2, gui.data.table,"codeParam2"..line, "plc_frame_param")
		content.codeParam2 = addGuiTextfield(content.codeParam2, content.codeFrameParam2, "plc_code_param2_"..line, code.params and code.params[2] or "", "plc_textfield", {"plc_tooltip.parameter2"})
		content.codeFrameParam3 = addGuiFrameH(content.codeFrameParam3, gui.data.table,"codeParam3"..line, "plc_frame_param")
		content.codeParam3 = addGuiTextfield(content.codeParam3, content.codeFrameParam3, "plc_code_param3_"..line, code.params and code.params[3] or "", "plc_textfield", {"plc_tooltip.parameter3"})
		
		if structure.data.runMode == true then
			content.del.enabled = false
			content.up.enabled = false
			content.dn.enabled = false
			content.codeCmd.enabled = false
			content.codeParam1.enabled = false
			content.codeParam2.enabled = false
			content.codeParam3.enabled = false
		else
			content.del.enabled = true
			content.up.enabled = true
			content.dn.enabled = true
			content.codeCmd.enabled = true
			content.codeParam1.enabled = commandList[code.cmd].params > 0
			content.codeParam2.enabled = commandList[code.cmd].params > 1
			content.codeParam3.enabled = commandList[code.cmd].params > 2
			if not content.codeParam1.enabled then content.codeParam1.text = "" end
			if not content.codeParam2.enabled then content.codeParam2.text = "" end
			if not content.codeParam3.enabled then content.codeParam3.text = "" end
		end

	end
end
function inputPage(gui, structure)
	-- page creation
	gui.data.table = addGuiTable(gui.data.table, gui.data.page,"plcProgramTable", 2)
	gui.data.tableHeader = gui.data.tableHeader or {{},{},{}}
	local header1 = gui.data.tableHeader[1]
	header1.cell = addGuiFrameH(header1.cell, gui.data.table,"header-1", "plc_frame_hidden")
	header1.label = addGuiLabel(header1.label, header1.cell, "label", "Signal")
	local header2 = gui.data.tableHeader[2]
	header2.cell = addGuiFrameH(header2.cell, gui.data.table,"header-2", "plc_frame_hidden")
	header2.label = addGuiLabel(header2.label, header2.cell, "label", "Variable", "plc_label_help_number")
	-- get number of lines from structure
	local insignalcount = structure.program.inputCount
	-- get the program data from structure
	gui.data.insignal = gui.data.insignal or {}
	for line = 1, insignalcount  do
		-- get the line or default it
		structure.program.inputs[line] = structure.program.inputs[line] or {signal = nil, name = ""}
		local entry = structure.program.inputs[line]
		-- display the line
		gui.data.insignal[line] = gui.data.insignal[line] or {}
		local content = gui.data.insignal[line]
		content.row = addGuiTable(content.row, gui.data.page,"plcSignalTable"..line, 2)
		content.signal = addGuiSignalButton(content.signal, content.row,"plc_input_signal_", line, nil, entry.signal, {"plc_tooltip.input_signal_select"})
		content.name = addGuiTextfield(content.name, content.row, "plc_input_name_"..line, entry.name , "textfield", {"plc_tooltip.input_variable_select"})
		if structure.data.runMode == true then
			content.signal.enabled = false
			content.name.enabled = false
		else
			content.signal.enabled = true
			content.name.enabled = true
		end
		
	end	
end
function outputPage(gui, structure)
	-- page creation
	gui.data.table = addGuiTable(gui.data.table, gui.data.page,"plcProgramTable", 2)
	gui.data.tableHeader = gui.data.tableHeader or {{},{},{}}
	local header1 = gui.data.tableHeader[1]
	header1.cell = addGuiFrameH(header1.cell, gui.data.table,"header-1", "plc_frame_hidden")
	header1.label = addGuiLabel(header1.label, header1.cell, "label", "Signal")
	local header2 = gui.data.tableHeader[2]
	header2.cell = addGuiFrameH(header2.cell, gui.data.table,"header-2", "plc_frame_hidden")
	header2.label = addGuiLabel(header2.label, header2.cell, "label", "Variable", "plc_label_help_number")
	-- get number of lines from structure
	local outsignalcount = structure.program.outputCount
	-- get the program data from structure
	gui.data.outsignal = gui.data.outsignal or {}
	for line = 1, outsignalcount  do
		-- get the line or default it
		structure.program.outputs[line] = structure.program.outputs[line] or {signal = nil, name = ""}
		local entry = structure.program.outputs[line]
		-- display the line
		gui.data.outsignal[line] = gui.data.outsignal[line] or {}
		local content = gui.data.outsignal[line]
		content.row = addGuiTable(content.row, gui.data.page,"plcSignalTable"..line, 2)
		content.signal = addGuiSignalButton(content.signal, content.row,"plc_output_signal_", line, nil, entry.signal, {"plc_tooltip.output_signal_select"})
		content.name = addGuiTextfield(content.name, content.row, "plc_output_name_"..line, entry.name , "textfield", {"plc_tooltip.output_variable_select"})
		if structure.data.runMode == true then
			content.signal.enabled = false
			content.name.enabled = false
		else
			content.signal.enabled = true
			content.name.enabled = true
		end
	end	
end
function savePage(gui, structure)
	-- page creation
	gui.data.content = gui.data.content or {}
	gui.data.content.frame = addGuiFrameV(gui.data.content.frame, gui.data.page,"r1cella", "plc_frame_hidden")
	local content = gui.data.content
	content.saveLabel = addGuiLabel(content.saveLabel, content.frame, "r1label", "Settings string can be copied to other PLC units", "plc_label_default")
	content.saveScroll = addGuiScrollPane(content.saveScroll, content.frame, "saveScroll", "plc_loadsave_pane", true, true)
	content.saveText = addGuiTextbox(content.saveText, content.saveScroll, "r1saveString", "", "plc_textbox_default", {"plc_tooltip.save_text"})
	content.loadLabel = addGuiLabel(content.loadLabel, content.frame, "r2label", "Settings string to be loaded into this PLC unit", "plc_label_default")
	content.loadScroll = addGuiScrollPane(content.loadScroll, content.frame, "loadScroll", "plc_loadsave_pane", true, true)
	content.loadText = addGuiTextbox(content.loadText, content.loadScroll, "r2loadString", "", "plc_textbox_default", {"plc_tooltip.load_text"})
	content.loadButton = addGuiButton(content.loadButton, content.frame, "plc_prgm_load", "", nil, "Load", {"plc_tooltip.load_program"})
	content.loadResultLabel = addGuiLabel(content.loadResultLabel, content.frame, "r2llabel", "", "plc_label_default")
	
	content.saveText.read_only = true
	content.saveText.word_wrap = true
	content.loadText.word_wrap = true
	
	local data = structure.program
	content.saveText.text = json_encode(data)
	
end
--   +-gui.main------------------------------------------+
--   |+-gui.container-----------------------------------+|
--   ||+-gui.menu--------------------------------------+||
--   |||+-gui.menutags--------------------------------+|||
--   ||||+-spacer-+-tab-+-spacer-+-tab-+-last-spacer-+||||
--   |||||        |     |        |     |             |||||
--   ||||+--------+-----+--------+-----+-------------+||||
--   |||+---------------------------------------------+|||
--   ||+-----------------------------------------------+||
--   ||+-gui.data--------------------------------------+||
--   |||                                               |||
--   |||                                               |||
--   ||+-----------------------------------------------+||
--   |+-------------------------------------------------+|
--   +---------------------------------------------------+

function drawGUI(player, player_index, structure)
	local done = true
	global.gui[player_index] = global.gui[player_index] or {}
	local gui = global.gui[player_index]
	gui.structure = structure
	gui.currentTab = gui.currentTab or "program"
	-- create main panel if needed
	gui.main = addGuiFrameV(gui.main, player.gui["center"], "plcMain", "plc_main_panel")
	-- create menu panel if needed
	gui.container = addGuiFrameV(gui.container, gui.main, "plcMenu", "plc_frame_default_fill")
	-- create data panel if needed
	gui.menu = addGuiTable(gui.menu, gui.container, "plcMenuTabs", 20, "plc_table_tab")
	-- create menu tabs if needed
	gui.menutabs = gui.menutabs or {}
	gui.menutabs.close = addMenuTab(gui.menutabs.close, gui.menu, "close", false, {"plc_tooltip.close_tab"})
	gui.menutabs.program = addMenuTab(gui.menutabs.program, gui.menu, "program", (gui.currentTab == "program"), {"plc_tooltip.program_tab"})
	gui.menutabs.input = addMenuTab(gui.menutabs.input, gui.menu, "input", (gui.currentTab == "input"), {"plc_tooltip.input_tab"})
	gui.menutabs.output = addMenuTab(gui.menutabs.output, gui.menu, "output", (gui.currentTab == "output"), {"plc_tooltip.output_tab"})
	gui.menutabs.save = addMenuTab(gui.menutabs.save, gui.menu, "save", (gui.currentTab == "save"), {"plc_tooltip.save_tab"})
	gui.menutabs.spacer = addGuiFrameH(gui.menutabs.spacer, gui.menu,"final","plc_final_tab")
	-- main data page. this has dynamic content depending on the tab selected
	gui.data = gui.data or {}
	gui.data.scroll = addGuiScrollPane(gui.data.scroll, gui.container, "dataScroll", "plc_program_pane", true, true)
	-- actual page where everything goes
	if not gui.lastTab or gui.lastTab ~= gui.currentTab or gui.update then
		if gui.data.page and gui.data.page.valid then
			gui.data.page.destroy()
			--gui.data = nil
		end
		gui.lastTab = gui.currentTab
	end
	gui.data.page = addGuiFrameV(gui.data.page, gui.data.scroll, "plcTitle", "plc_frame_section", {"plc_title."..gui.currentTab})
	-- fill the page area (it's ok if we don't, it's just an empty window)
	if gui.currentTab == "program" then
		programPage(gui, structure)
	elseif gui.currentTab == "input" then
		inputPage(gui, structure)
	elseif gui.currentTab == "output" then
		outputPage(gui, structure)
	elseif gui.currentTab == "save" then
		savePage(gui, structure)
	end
end



function hideGUI(player, index)
	if global.gui[index].main and global.gui[index].main.valid then global.gui[index].main.destroy() end
	global.gui[index] = nil
end

local function onClick(event)
	local player = game.players[event.player_index]
    if not event.element or not event.element.name or not string.match(event.element.name,"^plc_") then return end
	local element = event.element
	local gui = global.gui[event.player_index]
	--ignored clicks handled to minimise code
	if string.match(element.name, "^plc_code_") then return end
	-- menu tab handling
	local tabName = string.match(element.name, "^plc_menu_(%a+)")
	if tabName then 
		if tabName == "close" then
			hideGUI(player, event.player_index)
		else
			gui.currentTab = tabName 
			drawGUI(player, event.player_index, gui.structure)
		end
		return
	end
	if element.name == "plc_prgm_run" then
		if gui.structure.data.runMode then 
			gui.structure.data.runMode = false
		else
			gui.structure.data.runMode = true
		end
		gui.data.runButton.style = gui.structure.data.runMode and "plc_iconbutton_time_selected" or "plc_iconbutton_time"
		gui.data.runLabel.caption = gui.structure.data.runMode and "Running" or "Stopped"
		drawGUI(player, event.player_index, gui.structure)
	end
	if not gui.structure.data.runMode and element.name == "plc_prgm_load" then
		if gui.data.content.loadText and gui.data.content.loadText.valid then
			local data = nil
			local ok, err = pcall(function() data = json_decode(gui.data.content.loadText.text) end)
			if not ok then
				gui.data.content.loadResultLabel.caption = "could not load settigs: "..err
			else
				if gui.structure then
					gui.structure.program = gui.structure.program or {}
					if data and data.inputCount then 
						gui.structure.program.inputCount = data.inputCount 
					end
					if data and data.inputs then 
						gui.structure.program.inputs = data.inputs 
					end
					if data and data.outputCount then 
						gui.structure.program.outputCount = data.outputCount 
					end
					if data and data.outputs then 
						gui.structure.program.outputs = data.outputs 
					end
					if data and data.programCount then 
						gui.structure.program.programCount = data.programCount 
					end
					if data and data.program then 
						gui.structure.program.program = data.program 
					end
				end
				gui.data.content.loadResultLabel.caption = "Settings loaded."
			end
		end
		return
	end
	-- program line delete
	local cmd, index = string.match(element.name, "^plc_prgm_(%a+)_(%d+)")
	if cmd and cmd ~= "" and index and index ~= "" then 
		index = tonumber(index)
		if cmd == "delete" then
			gui.structure.program.program[index] = {cmd = 1, params = {}}
			drawGUI(player, event.player_index, gui.structure)
			return
		end
		if cmd == "movedn" and index < gui.structure.program.programCount then
			local tmp1 = gui.structure.program.program[index]
			local tmp2 = gui.structure.program.program[index + 1]
			gui.structure.program.program[index] = tmp2
			gui.structure.program.program[index + 1] = tmp1
			drawGUI(player, event.player_index, gui.structure)
		end
		if cmd == "moveup" and index > 1 then
			local tmp1 = gui.structure.program.program[index]
			local tmp2 = gui.structure.program.program[index - 1]
			gui.structure.program.program[index] = tmp2
			gui.structure.program.program[index - 1] = tmp1
			drawGUI(player, event.player_index, gui.structure)
		end
	end
	
	
	
	-- xyz handling
	--player.print("Unhandled event onClick - element.name = "..element.name)
	
end

local function onGuiChanged(event)
 	local player = game.players[event.player_index]
	local gui = global.gui[event.player_index]
    if not event.element or not event.element.name or not string.match(event.element.name,"^plc_") then return end
	local element = event.element
	-- menu tab handling
	local field = string.match(element.name, "^plc_input_name_(%d+)")
	if field and field ~= "" then 
		gui.structure.program.inputs[tonumber(field)].name = element.text
		return
	end
	local field = string.match(element.name, "^plc_output_name_(%d+)")
	if  field and field ~= "" then 
		gui.structure.program.outputs[tonumber(field)].name = element.text
		return
	end
	local field = string.match(element.name, "^plc_input_signal_(%d+)")
	if  field and field ~= "" then 
		gui.structure.program.inputs[tonumber(field)].signal = element.elem_value
		return
	end
	local field = string.match(element.name, "^plc_output_signal_(%d+)")
	if  field and field ~= "" then 
		gui.structure.program.outputs[tonumber(field)].signal = element.elem_value
		return
	end
	local field1 , field2 = string.match(element.name, "^plc_code_param(%d)_(%d+)")
	if field1 and field1 ~= "" and field2 and field2 ~= "" then 
		gui.structure.program.program[tonumber(field2)].params[tonumber(field1)] = element.text
		return
	end
	local field1 = string.match(element.name, "^plc_code_cmd_(%d+)")
	if field1 and field1 ~= "" then 
		gui.structure.program.program[tonumber(field1)].cmd = element.selected_index
		drawGUI(player, event.player_index, gui.structure)
		return
	end
	
	--player.print("Unhandled event onGuiChanged - element.name = "..element.name)
end


local function onTick(event)
	for _,struct in pairs(global.structures) do
		if not struct.entities or not struct.entities.main or not struct.entities.main.valid then
			unmanageStructure(struct)
			return
		end
		tickStructure(struct)
	end
    -- cleanup orphaned ghosts
    for _, ghostset in pairs(global.ghosts) do
        if not ghostset.entity.valid then
            local ghosts = ghostset.surface.find_entities_filtered{
                area={{ghostset.position.x - 1.5, ghostset.position.y - 1.5}, {ghostset.position.x + 1.5, ghostset.position.y + 1.5}},
                name="entity-ghost",
                ghostset.force}
            for _, each_ghost in pairs(ghosts) do
                if 	each_ghost.ghost_name == "plc-power" or 
					each_ghost.ghost_name == "plc-input" or 
					each_ghost.ghost_name == "plc-output" then
						each_ghost.destroy()
                end
            end
            global.ghosts[_] = nil
        end
    end
end

local function onCustomInput(event)
	local player = game.players[event.player_index]
	if player.selected and player.selected.name == "plc-unit" then
		local structure = getStructureForEntity(player.selected)
		drawGUI(player, event.player_index, getStructureForEntity(player.selected))
	end
end
script.on_event(defines.events.on_gui_click, onClick)
script.on_event(defines.events.on_gui_text_changed, onGuiChanged)
script.on_event(defines.events.on_gui_elem_changed, onGuiChanged)
script.on_event(defines.events.on_gui_selection_state_changed, onGuiChanged)


script.on_event("open-plc", onCustomInput)
script.on_event(defines.events.on_tick, onTick)
script.on_init(onInit)
