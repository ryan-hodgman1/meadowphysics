setup_params = function(mp)

  -- Voices
    params:add{
      type = "option", id = "scale", name = "scale",
      options = {"major", "minor", "dorian"},
      action = function(value)
      end
    }

    for i=1, mp.voice_count do
      print("setup voice params")
      params:add_separator()
      local id = "voice_" .. i .. "_"
      local name = "Voice " .. i .. " "

      params:add{
        type = "number",
        id = (id .. "_min_cycle"),
        name = (name .. "min cycle"),
        min = 1,
        max = 15,
        default = 8,
        action = function(value)
          print("change " .. name .. "min cycle")
        end
      }

      params:add{
        type = "number",
        id = (id .. "_max_cycle"),
        name = (name .. "max cycle"),
        min = 2,
        max = 16,
        default = 8,
        action = function(value)
          print("change " .. name .. "max cycle")
        end
      }

      params:add{
        type = "option",
        id = (id .. "_rule"),
        name = (name .. "rule"),
        options = {"increment", "decrement", "min", "max", "polar", "random", "none"},
        action = function(value)

        end
      }

      params:add{
        type = "number",
        id = (id .. "_midi_note"),
        name = (name .. "midi note"),
        min = 1,
        max = 99,
        default = i,
        action = function(value)
          print("change " .. name .. "midi note")
        end
      }

      for ti=1, mp.voice_count do
        params:add{
          type = "option",
          id = (id .. "_triggers_" .. ti),
          name = (name .. " triggers " .. ti),
          options = {"yes", "no"},
          action = function(value)

          end
        }
      end

      for ri=1, mp.voice_count do
        local rid = (id .. "_rules_" .. ri)
        params:add{
          type = "option",
          id = rid,
          name = (name .. " rules " .. ri),
          options = {"yes", "no"},
          action = function(value)

          end
        }
      end

    end

end

return setup_params