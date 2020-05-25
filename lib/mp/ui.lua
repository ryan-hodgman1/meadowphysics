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
        if vi >= params:get(i .. "_range_low") and vi <= params:get(i .. "_range_high") then
          screen.level(3)
        end
        if voice.current_step == vi and voice.isRunning() then 
          screen.level(16)
        end
        screen.rect(gx, gy, 2, 2)
        screen.fill()
        gx = gx + padding
        screen.level(1)
      end
    end
  end

  return mp_ui

end

return meadowphysics_ui