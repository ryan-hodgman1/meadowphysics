-- Meadowphysics screen ui
local meadowphysics_ui = {}

function meadowphysics_ui.new (mp)

  local mp_ui = {}

  function mp_ui:draw ()
    screen.aa(0)
    local offset_x = 35
    local offset_y = 18
    local padding = 4
    
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
      for i = 1, 16 do
        screen.rect(gx, gy, 1, 1)
        screen.fill()
        screen.stroke()
        gx = gx + padding
      end
      if voice.current_step >= 1 then
        local y = ((i - 1) * 4) + offset_y
        local x = 0
        x = ((voice.current_step - 1) * padding) + offset_x
        -- screen.level(1)
        if voice.current_step == voice.current_cycle_length and voice.is_playing then
          screen.level(16)
        elseif voice.is_playing then
          screen.level(4)
        end
        screen.move(x, y)
        screen.rect(x, y, 1, 1)
        screen.fill()
        screen.level(3)

        -- fireball trails :3
        -- screen.rect(x+1, y, 1, 1)
        -- screen.fill()
        -- screen.level(2)
        -- screen.rect(x+2, y, 1, 1)
        -- screen.fill()
        -- screen.stroke()
        -- screen.level(1)
        -- screen.rect(x+3, y, 1, 1)
        -- screen.fill()
        -- screen.stroke()

      end
    end
  end

  return mp_ui

end

return meadowphysics_ui