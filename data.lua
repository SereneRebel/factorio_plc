require("prototypes.font")
require("prototypes.style")
require("prototypes.entity")
require("prototypes.technology")
require("prototypes.recipe")
data:extend
{
    {
        type = "item-subgroup",
        name = "plc",
        group = "logistics",
        order = "g-b"
    }
}
-- Add keys
data:extend{
    {
        type = "custom-input",
        name = "open-plc",
        key_sequence = "mouse-button-1",
        consuming = "script-only"
    }
}
data:extend{
    {
        type = "custom-input",
        name = "close-plc",
        key_sequence = "",
		linked_game_control = "close-gui",
        consuming = "none"
    }
}
data:extend{
    {
        type = "custom-input",
        name = "close-plc2",
        key_sequence = "",
		linked_game_control = "toggle-menu",
        consuming = "none"
    }
}

