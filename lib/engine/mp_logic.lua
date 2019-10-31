-- 

local mp = {}

mp.create_voice = function()
  local voice = {}
  voice.speed = 1
  voice.current_tick = 1
  voice.position = 8
  voice.rule = "dec"
  voice.siblings = {}
  voice.min_cycle_length = 8
  voice.max_cycle_length = 12
  voice.current_cycle_length = 8
  voice.mode = "trigger" -- or "gate"
  
  voice.step = function()
    if (voice.trigger_on_next_step == true) then
      voice.trigger_on_next_step = false
      -- Play trigger
      -- Reset values
    end
    if voice.position == 1 and voice.step == 1 then
      voice.trigger_on_next_step = true
      else
        --Tick down the voice
    end
  end
  
  voice.trigger = function()
    -- emit trigger event (code which calls this can deduce whether to trigger or gate based on voice.mode)
  end
  
  voice.apply_rule = function()

  end
  
  return voice
end

return mp

