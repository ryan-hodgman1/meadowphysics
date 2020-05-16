setup_params = function(mp)

  -- Voices
  params:add {
    type = "option",
    id = "output",
    name = "output",
    options = {"audio", "midi", "audio + midi"}
  }

  params:add{
  	type = "number",
  	id = "midi_out_device",
  	name = "midi out device",
    min = 1,
    max = 4,
    default = 1,
    action = function(value)
			mp.midi_out_device = midi.connect(value)
		end
	}

  params:add{
  	type = "number",
  	id = "midi_out_channel",
  	name = "midi out channel",
    min = 1, max = 16, default = 1,
    action = function(value)
      mp.midi_out_channel = value
    end
  }

  params:add {
    type = "option",
    id = "clock_division",
    name = "clock division",
    options = {"1/4", "1/8", "1/12", "1/16"}
  }

  params:add_separator()

end

return setup_params