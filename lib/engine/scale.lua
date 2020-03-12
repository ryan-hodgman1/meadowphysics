local MusicUtil = require "musicutil"

scale = {}

scale.notes = {

}

function scale:make_params()

  params:add{
    type = "number",
    id = "root_note",
    name = "root note",
    min = 0,
    max = 127,
    default = 60, formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end,
    action = function() scale:build() end
  }

  local scale_names = {}

  for i = 1, #MusicUtil.SCALES do
    table.insert(scale_names, string.lower(MusicUtil.SCALES[i].name))
  end

  params:add{
    type = "option",
    id = "scale_mode",
    name = "scale mode",
    options = scale_names,
    default = 5,
    action = function() scale:build() end
  }

  scale:build()

end

function scale:build()
  scale.notes = MusicUtil.generate_scale_of_length(params:get("root_note"), params:get("scale_mode"), 16)
  local num_to_add = 8 - #notes
  for i = 1, num_to_add do
    table.insert(scale.notes, scale.notes[16 - num_to_add])
  end
end

return scale