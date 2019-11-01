-- Meadowphysics screen ui

mp_ui = {}

function mp_ui:draw(mp)
  screen.move(4, 16)
  screen.text(mp:get_state(1))
  screen.move(4, 24)
  screen.text(mp:get_state(2))
  print("DRAW")
end

return mp_ui