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
        key_sequence = "Left mouse button",
        consuming = "script-only"
    }
}
