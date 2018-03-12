data:extend({
  {
    type = "technology",
    name = "plc",
    icon = "__plc__/graphics/icon/plc.png",
    icon_size = 128,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "plc-unit"
      }
    },
    prerequisites = {"circuit-network"},
    unit =
    {
      count = 200,
      ingredients = {
        {"science-pack-1", 1},
        {"science-pack-2", 1}
      },
      time = 15
    },
    order = "e-a-b"
  }
})
