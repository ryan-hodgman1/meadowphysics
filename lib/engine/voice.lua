local voice_count = 8

create_voice = function(i, mp)

  local get = function (param)
    return params:get(i .. "_" .. param)
  end

  local set = function (param, value)
    params:set(i .. "_" .. param, value)
  end


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

  set("reset_" .. i, 2)

  local v = {}
  v.index = i
  v.current_tick = 0
  v.current_step = get("range_low")
  v.target_voices = { false, false, false, false, false, false, false, false }
  v.current_cycle_length = get("range_low")
  v.bang_type = get("type")
  v.gate = 0 -- 0 or 1
  v.get = get
  v.set = set

  v.on_bang = function() end

  v.isRunning = function ()
    if get("running") == 2 then
      return true
    else
      return false
    end
  end

  v.tick = function()
    -- Clock hits this function for every tick, the clock multiplication affects the amount of ticks
    -- per step, when current_tick hits 0, the current step will step down towards zero.
    -- when it hits zero it resets to a step value determined by it's rule, and emits a bang

    if not v.isRunning() then return end

    -- Reset tick clock and advance step (toward zero) when hitting the clock division
    if (v.current_tick == get("clock_division")) then
      v.current_tick = 0
      v.current_step = v.current_step - 1
    end

    if (v.current_step == 0) then
      v.current_step = v.current_cycle_length
    end

    if v.current_tick == 0 and v.current_step == v.current_cycle_length and not v.just_triggered then
      for i=1, voice_count do
        if get("reset_" .. i) == 2 then
          local voice = mp.voices[i]
          voice.bang()
          voice.just_triggered = true
          voice.current_tick = 0
          voice.apply_rule(rules[get("rule")])
          voice.current_step = voice.current_cycle_length
        end
      end

    end

    v.current_tick = v.current_tick + 1
    v.just_triggered = false

  end

  v.toggle_target = function(voice_index)
    if get("reset_" .. voice_index) == 2 then
      set("reset_" .. voice_index, 1)
    else
      set("reset_" .. voice_index, 2)
    end
  end

  v.toggle_playback = function()
    if (v.isRunning()) then set("running", 1) else set("running", 2) end
  end

  v.set_bang_type = function(bang_type)
    set("type", bang_type)
  end

  v.set_clock_division = function(division)
    print("set ticks per step", division)
    v.current_tick = division
    set("clock_division", division)
  end

  v.bang = function()
    set("running", 2)
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
      if v.current_cycle_length > get("range_high") then
        v.current_cycle_length = get("range_low")
      end
    end
    if rule == "decrement" then
      v.current_cycle_length = v.current_cycle_length - 1
      if v.current_cycle_length < get("range_low") then
        v.current_cycle_length = get("range_high")
      end
    end
    if rule == "max" then
      v.current_cycle_length = get("range_high")
    end
    if rule == "min" then
      v.current_cycle_length = get("range_low")
    end
    if rule == "random" then
      local delta = get("range_high") - get("range_low")
      v.current_cycle_length = get("range_low") + math.random(delta)
    end
    if rule == "pole" then
      if v.current_cycle_length == get("range_high") then
        v.current_cycle_length = get("range_low")
      else
        v.current_cycle_length = get("range_high")
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