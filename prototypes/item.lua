local FOLDER = "__SignalController__"

data:extend({
    {
        type = "item-subgroup",
        name = "plc",
        group = "logistics",
        order = "g-b"
    },
    {
        type = "item",
        name = "plc-unit",
        icon = FOLDER .. "/graphics/icon/plc.png",
        icon_size = 128,
        subgroup = "plc",
        order = "b",
        stack_size = 50,
        place_result = "plc-unit",
    },
    {
        type = "item",
        name = "plc-input",
        icon = FOLDER .. "/graphics/icon/plc.png",
        icon_size = 128,
        flags = { "hidden" },
        subgroup = "plc",
        order = "z[plc]",
        stack_size = 50,
        place_result = "plc-input",
    },
    {
        type = "item",
        name = "plc-output",
        icon = FOLDER .. "/graphics/icon/plc.png",
        icon_size = 128,
        flags = { "hidden" },
        subgroup = "plc",
        order = "z[plc]",
        stack_size = 50,
        place_result = "plc-output",
    },
})
