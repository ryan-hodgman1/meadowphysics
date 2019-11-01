-- Meadowphysics screen ui

ui = {}

function ui:redraw(mp)
  screen.move(4, 16)
  screen.text(mp:get_state(1))
  screen.move(4, 24)
  screen.text(mp:get_state(2))
end

return ui