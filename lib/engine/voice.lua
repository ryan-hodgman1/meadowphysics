

create_voice = function(i, mp)
  local bool = {"no", "yes"}
  local rules = {"increment", "decrement", "max", "min", "random", "pole", "stop"}

  params:add_group("Voice " .. i, 14)

  params:add {
    type = "option",
    id = i .. "_running",
    name = "running",
    options = bool
  }

  params:add{
    type = "number",
    id = i .. "_range_low",
    name = "range low",
    min=1,
    max=16, 
    default = 8,
  }

  params:add{
    type = "number",
    id = i .. "_range_high",
    name = "range high",
    min=1,
    max=16, 
    default = 8,
  }

  params:add{
    type = "number",
    id = i .. "_clock_division",
    name = "clock division",
    min=1,
    max=8, 
    default = 1,
  }

  params:add {
    type = "option",
    id = i .. "_type",
    name = "type",
    options = {"trigger", "gate"}
  }

  params:add {
    type = "option",
    id = i .. "_rule",
    name = "rule",
    options = rules
  }

  for reset_i=1,8 do
    params:add {
      type = "option",
      id = i .. "_reset_" .. reset_i,
      name = "resets " .. reset_i,
      options = bool
    }
  end

  local get = function (param)
    return params:get(i .. "_" .. param)
  end

  local set = function (param, value)
    params:set(i .. "_" .. param, value)
  end

  local v = {}
  v.index = i
  v.ticks_per_step = get("clock_division")
  v.current_tick = 0
  v.current_step = get("range_low")
  v.rule = get("rule")
  v.is_playing = false
  v.target_voices = { false, false, false, false, false, false, false, false }
  v.target_voices[i] = true
  v.min_cycle_length = get("range_low")
  v.max_cycle_length = get("range_high")
  v.current_cycle_length = get("range_low")
  v.bang_type = get("type")
  v.gate = 0 -- 0 or 1

  v.on_bang = function() end

  v.tick = function()
    -- Clock hits this function for every tick, the clock multiplication affects the amount of ticks
    -- per step, when current_tick hits 0, the current step will step down towards zero.
    -- when it hits zero it resets to a step value determined by it's rule, and emits a bang

    -- if get("running") == "no" then return end

    -- Reset tick clock and advance step (toward zero) when hitting the clock division
    if (v.current_tick == v.ticks_per_step) then
      v.current_tick = 0
      v.current_step = v.current_step - 1
    end

    if (v.current_step == 0) then
      v.current_step = v.current_cycle_length
    end

    if v.current_tick == 0 and v.current_step == v.current_cycle_length and not v.just_triggered then
      for i=1, #v.target_voices do
        if v.target_voices[i] == true then
          local voice = mp.voices[i]
          voice.bang()
          voice.just_triggered = true
          voice.current_tick = 0
          voice.apply_rule(v.rule)
          voice.current_step = voice.current_cycle_length
        end
      end
    end

    v.current_tick = v.current_tick + 1
    v.just_triggered = false

  end

  v.toggle_target = function(voice_index)
    if v.target_voices[voice_index] == false then
      print("Voice ", voice_index, "will now be triggered by voice ", v.index)
      v.target_voices[voice_index] = true
    else
      print("Voice ", voice_index, "will no longer be triggered by voice ", v.index)
      v.target_voices[voice_index] = false
    end
  end

  v.toggle_playback = function()
    if (get("running") == "yes") then set("running", "no") else set("running", "yes") end
  end

  v.set_bang_type = function(bang_type)
    print("set bang type of ", v.index, " to ", bang_type)
    v.bang_type = bang_type
  end

  v.set_clock_division = function(division)
    print("set ticks per step", division)
    v.current_tick = division
    v.ticks_per_step = division
  end

  v.bang = function()
    -- set("running", "yes")
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
      v.is_playing = true -- is this needed?
      v.current_step = v.current_cycle_length
    end
  end

  return v
end

return create_voice