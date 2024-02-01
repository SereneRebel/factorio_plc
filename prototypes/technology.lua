data:extend({
  {
    type = "technology",
    name = "signal-controller",
    icon = "__SignalController__/graphics/icon/plc.png",
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
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 15
    },
    order = "e-a-b"
  }
})
