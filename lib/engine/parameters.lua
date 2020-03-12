setup_params = function(mp)

  -- Voices

  params:add{
    type = "number",
    id = ("tempo"),
    name = ("tempo"),
    min = 60,
    max = 240,
    default = 120,
    action = function(value)
      mp.clock:bpm_change(value)
    end
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


end

return setup_params