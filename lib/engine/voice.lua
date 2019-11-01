

create_voice = function(i)
  local start_length = math.floor(math.random()*12)+4
  local start_ticks = math.floor(math.random(3)+1)
  start_length = 8
  start_ticks = 4
  local v = {}
  v.index = i
  v.ticks_per_step = start_ticks
  v.current_tick = 4
  v.current_step = start_length
  v.rule = "dec"
  v.target_voices = {v}
  v.min_cycle_length = 8
  v.max_cycle_length = 8
  v.current_cycle_length = start_length
  v.bang_type = "trigger" -- or "gate"
  v.gate = false
  v.on_bang = function() end
  
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
        v.target_voices[i].apply_rule()
        v.target_voices[i].reset()
      end
    end
    
  end
  
  v.bang = function()
    if v.bang_type == "gate" then
      v.gate = not v.gate
    end
    local bang = {}
    bang.type = v.bang_type
    bang.voice = v.index
    bang.gate = v.gate
    v.on_bang(bang)
  end
  
  v.reset = function ()
    v.current_step = v.current_cycle_length
    v.current_tick = v.ticks_per_step
  end
  
  v.apply_rule = function()

  end
  
  print("created voice")
  return v
end

return create_voice