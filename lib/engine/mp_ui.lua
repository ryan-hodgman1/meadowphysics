-- Meadowphysics screen ui

mp_ui = {}

function mp_ui:draw(mp)

  screen.aa(0)
  local offset_x = 35
  local offset_y = 16
  local padding = 4

  -- Draw position of each tracker on the norns screen
  for i = 1, #mp.voices do
    local voice = mp.voices[i]
    screen.level(1)
    screen.move(offset_x, offset_y)
    local gx = offset_x
    local gy = offset_y + (padding * (i-1))
    
    for i = 1, 16 do
      screen.rect(gx, gy, 1, 1)
      screen.fill()
      screen.stroke()
      gx = gx+padding
    end
    
    if voice.current_step >= 1 then
      local y = ((i - 1) * 4) + offset_y
      local x = 0
      x = ((voice.current_step - 1) * padding) + offset_x
      if voice.current_step == 1 then
        screen.level(16)
      else
        screen.level(3)
      end
      screen.move(x, y)
      screen.rect(x, y, 1, 1)
      screen.fill()
      screen.stroke()
    end
  end
  
  
  
  
end

return mp_ui