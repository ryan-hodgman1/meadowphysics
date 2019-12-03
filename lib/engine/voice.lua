

create_voice = function(i)
  -- local start_length = math.floor(math.random()*12)+4
  -- local start_ticks = math.floor(math.random(3)+1)
  start_length = 8
  start_ticks = 1
  local v = {}
  v.index = i
  v.ticks_per_step = start_ticks
  v.current_tick = 0
  v.current_step = start_length
  v.rule = "increment"
  v.is_playing = false
  v.target_voices = {}
  v.min_cycle_length = start_length
  v.max_cycle_length = start_length
  v.current_cycle_length = start_length
  v.bang_type = "trigger" -- or "gate"
  v.gate = false
  v.on_bang = function() end

  v.tick = function()
    -- Clock hits this function for every tick, the clock multiplication affects the amount of ticks
    -- per step, when current_tick hits 0, the current step will step down towards zero.
    -- when it hits zero it resets to a step value determined by it's rule, and emits a bang

    if not v.is_playing then return end

    -- Reset tick clock and advance step (toward zero) when hitting the clock division
    if (v.current_tick == v.ticks_per_step) then
      v.current_tick = 0
      v.current_step = v.current_step - 1
    end

    if (v.current_step == 0) then
      v.current_step = v.current_cycle_length
      v.is_playing = false
    end

    if v.current_tick == 0 and v.current_step == v.current_cycle_length and not v.just_triggered then
      for i=1, #v.target_voices do
        local voice = v.target_voices[i]
        voice.bang()
        voice.just_triggered = true
        voice.current_tick = 0
        voice.apply_rule(v.rule)
        voice.current_step = voice.current_cycle_length
        voice.is_playing = true
      end
    end

    v.current_tick = v.current_tick + 1
    v.just_triggered = false

  end

  v.add_target = function(voice)

    -- table.insert(v.target_voices, voice)
    -- v.target_voices[voice.index] = voice
  end

  v.remove_target = function(voice)
    -- v.target_voices[voice.index] = nil
  end

  v.set_bang_type = function(bang_type)
    v.bang_type = bang_type
  end

  v.set_clock_division = function(division)
    print("set ticks per step", division)
    v.current_tick = division
    v.ticks_per_step = division
  end

  v.bang = function()
    -- v.is_playing = true
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
    print("reset voice")
    v.current_step = v.current_cycle_length
    v.current_tick = 1
  end

  v.apply_rule = function(rule)
    if rule == "increment" then
      v.current_cycle_length = v.current_cycle_length + 1
      if v.current_cycle_length > v.max_cycle_length then
        v.current_cycle_length = v.min_cycle_length
      end
    end
    if rule == "decrement" then
      v.current_cycle_length = v.current_cycle_length - 1
      if v.current_cycle_length < v.min_cycle_length then
        v.current_cycle_length = v.max_cycle_length
      end
    end
    if rule == "max" then
      v.current_cycle_length = v.max_cycle_length
    end
    if rule == "min" then
      v.current_cycle_length = v.min_cycle_length
    end
    if rule == "random" then
      local delta = v.max_cycle_length - v.min_cycle_length
      v.current_cycle_length = v.min_cycle_length + math.random(delta)
    end
    if rule == "pole" then
      if v.current_cycle_length == v.max_cycle_length then
        v.current_cycle_length = v.min_cycle_length
      else
        v.current_cycle_length = v.max_cycle_length
      end
    end
    if rule == "stop" then
      v.target_voices = {}
      v.is_playing = true
      v.current_step = v.current_cycle_length
    end
  end

  return v
end

return create_voice