

create_voice = function(i)
  local v = {}
  v.index = i
  v.ticks_per_step = 4
  v.current_tick = 4
  v.current_step = 4
  v.rule = "dec"
  v.target_voices = {}
  v.min_cycle_length = 4
  v.max_cycle_length = 4
  v.current_cycle_length = 4
  v.mode = "trigger" -- or "gate"
  
  v.tick = function()
    -- Clock hits this function for every tick, the clock multiplication affects the amount of ticks
    -- per step, when current_tick hits 0, the current step will step down towards zero.
    -- when it hits zero it resets to a step value determined by it's rule, and emits a bang
    
    if v.current_tick >= 1 then
      v.current_tick = v.current_tick - 1
    end
    
    if v.current_tick == 0 and v.current_step >= 1 then
      v.current_tick = v.ticks_per_step
      if v.current_step >= 1 then
        v.current_step = v.current_step - 1
      end
    end
    if v.current_step == 0 then -- dont have to check if tick is 0 because it has to be for step to be 0
      for i=1, #v.target_voices do
        v.target_voices[i].bang()
      end
    end
    
  end
  
  v.bang = function()
    v.apply_rule()
    -- emit trigger event (code which calls this can deduce whether to trigger or gate based on voice.mode)
    -- print("voice", v.index, "BANG")
  end
  
  v.apply_rule = function()
    v.current_step = v.current_cycle_length
    v.current_tick = v.ticks_per_step
  end
  
  print("created voice")
  return v
end

return create_voice