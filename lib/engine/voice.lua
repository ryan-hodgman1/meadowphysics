

create_voice = function(i)
  local v = {}
  v.index = i
  v.ticks_per_step = 4
  v.current_tick = 1
  v.current_step = 8
  v.rule = "dec"
  v.siblings = {i}
  v.min_cycle_length = math.floor(math.random()*4)
  v.max_cycle_length = math.floor(math.random()*12)
  v.current_cycle_length = 8
  v.mode = "trigger" -- or "gate"
  
  v.tick = function()
    -- Clock hits this function for every tick, the clock multiplication affects the amount of ticks
    -- per step, when current_tick hits 0, the current step will step down towards zero.
    -- when it hits zero it resets to a step value determined by it's rule, and emits a bang
    v.current_tick = v.current_tick - 1
    if v.current_tick == 0 then
      v.current_tick = v.ticks_per_step
      v.current_step = v.current_step - 1
    end
    if v.current_step == 0 then
      v.bang()
    end
    
  end
  
  v.bang = function()
    v.apply_rule()
    -- emit trigger event (code which calls this can deduce whether to trigger or gate based on voice.mode)
    -- print("voice", v.index, "BANG")
  end
  
  v.apply_rule = function()
    v.current_step = v.max_cycle_length
  end
  
  print("created voice")
  return v
end

return create_voice