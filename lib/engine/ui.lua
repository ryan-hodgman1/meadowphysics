-- Meadowphysics screen ui
local meadowphysics_ui = {}

function meadowphysics_ui.new (mp)

  local mp_ui = {}

  function mp_ui:draw ()
    screen.aa(0)
    local offset_x = 20
    local offset_y = 8

    local padding = 6
    
    if #mp.voices > 8 then
      offset_y = 2
    end

    -- Draw position of each tracker on the norns screen
    for i = 1, #mp.voices do
      local voice = mp.voices[i]
      screen.level(1)
      screen.move(offset_x, offset_y)
      local gx = offset_x
      local gy = offset_y + (padding * (i-1))
      for vi = 1, 16 do
        screen.rect(gx, gy, 2, 2)
        screen.fill()
        gx = gx + padding
      end
      if voice.current_step >= 1 then
        local x = ((voice.current_step - 1) * padding) + offset_x
        local y = ((i - 1) * padding) + offset_y
        if voice.current_step == voice.current_cycle_length and voice.isRunning() then
          screen.level(16)
        elseif voice.isRunning() then
          screen.level(4)
        end
        -- screen.move(x, y)
        screen.rect(x, y, 2, 2)
        screen.fill()
        screen.level(3)


      end
    end
  end

  return mp_ui

end

return meadowphysics_ui