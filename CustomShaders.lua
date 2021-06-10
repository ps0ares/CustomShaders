local obs = obslua
local bit = require("bit")
local cs = {}
local source_def = {}
source_def.id = 'filter-custom'
source_def.type = obs.OBS_SOURCE_TYPE_FILTER
source_def.output_flags = bit.bor(obs.OBS_SOURCE_VIDEO)

EFFECT_FILE_FILTER = 'Shader File (*.effect *.shader *.glsl);; All Files (*.*)'
IMAGE_FILE_FILTER = 'Image (*.png *.jpeg *.jpg *.gif *.bmp *.tga *.psd *.webp);; All Files (*.*)'

cs.set_effect_param = {int = obs.gs_effect_set_int, int2 = obs.gs_effect_set_vec2, int3 = obs.gs_effect_set_vec3, int4 = obs.gs_effect_set_vec4, float = obs.gs_effect_set_float, float2 = obs.gs_effect_set_vec2, float3 = obs.gs_effect_set_vec3, float4 = obs.gs_effect_set_vec4, bool = obs.gs_effect_set_bool, texture2d = obs.gs_effect_set_texture}

cs.get_property = {int = obs.obs_data_get_int, float = obs.obs_data_get_double, bool = obs.obs_data_get_bool, float4 = obs.obs_data_get_int, texture2d = obs.obs_data_get_string}

cs.set_property = {int = obs.obs_data_set_int, float = obs.obs_data_set_double, bool = obs.obs_data_set_bool, float4 = obs.obs_data_set_int, texture2d = obs.obs_data_set_string}

cs.add_property = {int = obs.obs_properties_add_int, int_slider = obs.obs_properties_add_int_slider, float = obs.obs_properties_add_float, float_slider = obs.obs_properties_add_float_slider}

cs.valid_types ={int = "ui", int2 = "gl", int3 = "gl", int4 = "gl", float = "ui", float2 = "gl", float3 = "gl", float4 = "ui", bool = "ui", texture2d = "ui"}

cs.params = {iResolution = {type = "float2"}, iTime = {type = "float"}, lTime = {type = "float3"}, rand_f = {type = "float"}}

cs.fallback_image = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQMAAADCCAAAAABoefiyAAADbElEQVR42u3cu46rQAyA4X3/R5opLDcIiZIKKVIqmilIRWfJp9hs7uQeTmb4p91VEj7suRp+nPYDAQYYYIABBhhggAEGGGCAAQYYYIABBhhggAEGGGCAAQYYYIABBhhggAEGGGCAAQYYYIABBhhggAEGGGCAAQYYYIABBrkamJnN8Jvf/TXvNpjlxn21wVzR+8UGPlTNHK3afHGfOASZo4Xhmw3iLAYRAwwwwCAvA/1Ey8ugqj/RqpwM3vwjP/zxGGCAAQb/wcBeXlvnbmDm9uoOQ+YG7yDI3WDsV+thuf2BmY1djBJjlV7bCszYwK0Ov3+Ia1+kgbm3QVREVCtJvkADM0+ioiIiKqH1ReaCdwdLf11mf+Dt4fbHuMz+oD3cXZo4GrDC+4O16EEuTBjYHSNGxnGwiTuD0E3e8U1f9Ni42h0/6dQpmXkTx5Lnytb8zg+ipkmCPsrNcTPr9YKtJUSJ7fRvtyh689KyjgP3cUjpWqy3QVXrkuPg5uA3BBXVsC59H2k6D8zqbZc5Xh0gSzbwbjtwxGapceDj3wRCQ78MA7Omt90Oq7lbs59M67iMOOgkdLbrJs37sJtM69XFdTkGQ9Ao9f5+j6oHcRCG6TGkHAMVqUSqze+1Hi8rNUo9PTQUYmDe/f1Pb7adJB+3rvg42JUoaOjM3Md9acWNLYZy4qA6uNhmdO/iGUJdsIHZPhO2LQ0Sz2qY4noiG0qIAzsp2opRVeQsFyYnCUXkgtXHF6zxAkHQqd2mEnLBu6DH13wpDFRE0sWVZglxMES9q/5Qpb74nEYJcVDfWYOpEleF5sLq/sp+lbHAXDBPDxXyNjaWZ2D6WE3yhUlC9rnQPviMi5YVB2bmKeiDxennOwl5ny+4VfKggcZ0OjzmnQvWhgcNVKQ6rWjM+4wlnU4Q71E4mzLn3R88ev27SUI5udDGpxCkKcegD8/FwelxQ771Bzbqs496RT0qX8o4DlK3erZ1fSFx8NJHFhIH9iYCnmPBAAMMMjVIHzFIxEFeccAz37z/AAMMMMAAg63BcxtGZb0rrGrqOdo3vzNutvbF7w7kPZq5NgwwwAADDDDAAAMMMMAAAwwwwAADDDDAAAMMMMAAAwwwwAADDDDAAAMMMMAAAwwwwAADDDDAAAMMMMAAAwwwwAADDDDAYN72DyBhjhBdLPstAAAAAElFTkSuQmCC"

cs.vertex_shader_sig = "VertDatamainTransform%(VertData[%w_]+%)"
cs.pixel_shader_sig = "float4mainImage%(VertData[%w_]+%):TARGET"

cs.effect_top = [[
uniform float4x4 ViewProj;
uniform texture2d image;
uniform float2 iResolution;
uniform float iTime;
uniform float3 lTime;
uniform float rand_f;

struct VertData {
   float4 pos : POSITION;
   float2 uv  : TEXCOORD0;
};

sampler_state textureSampler {
   Filter = Linear;
   AddressU = Border;
   AddressV = Border;
   BorderColor = 00000000;
};
]]

cs.effect_vertex = [[
VertData mainTransform(VertData v_in)
{
   VertData vert_out;
   vert_out.pos = mul(float4(v_in.pos.xyz, 1.0), ViewProj);
   vert_out.uv  = v_in.uv;
   return vert_out;
}
]]

cs.effect_pixel = [[
float4 mainImage(VertData v_in) : TARGET
{
   return image.Sample(textureSampler, v_in.uv);
}
]]

cs.effect_default_pixel = [[
float4 mainImage(VertData v_in) : TARGET
{
   return float4(0.5 + 0.5*cos(iTime+v_in.uv.xyx+float3(0,2,4)), 1.0);
}
]]

cs.effect_bottom = [[
technique Draw
{
   pass
   {
      vertex_shader = mainTransform(v_in);
      pixel_shader  = mainImage(v_in);
   }
}
]]

cs.fallback_effect = cs.effect_top .. cs.effect_vertex .. cs.effect_default_pixel .. cs.effect_bottom

function script_load(settings)
   obs.obs_register_source(source_def)
end

function script_description()
   return [[<center><h2>Custom shaders 0.9</h2></center>
   <p>This Lua script provides a filter that applies <em>OBS effects</em> to any image source.</p><b>Shade away!</b><p>--<br>Paulo Soares</p>]]
end

function source_def.get_name()
   return 'Custom Shader'
end

function read_file(filter)
   local counter, content = 0, cs.effect_top
   local k , v, signature, pragma, line, line_t, token, num, n, typeof, name, value
   local f, err = io.open(filter.effect_path)
   cs.vertex_shader_template = true
   cs.pixel_shader_template = true

   if f == nil then
      print('Failed to open file: ' .. err)
      return cs.fallback_effect
   else
      for line in f:lines() do
         line = line:gsub("vec([234])", "float%1"):gsub("%s*$", ""):gsub("//.*", "")
         signature = line:gsub("%s*", ""):gsub('[{]', "")
         if signature:match(cs.vertex_shader_sig) ~= nil then
            cs.vertex_shader_template = false
         elseif signature:match(cs.pixel_shader_sig) ~= nil then
            cs.pixel_shader_template = false
         end
         -- Pragmas --------------------------------------------------------------------------
         if line:find('^[%s]*#pragma') then
            line = line:match('[%s]*#pragma[%s]*(.*)$')
            line = line:gsub("[%s]*,[%s]*", ","):gsub("[%s]+", "#")
            pragma = {}
            for token in string.gmatch(line, "[^#]+") do
               table.insert(pragma, token)
            end
            name = pragma[1]
            filter.pragmas[name] = {}
            counter = counter + 1
            filter.pragmas[name].order = counter
            value = {}
            for token in string.gmatch(pragma[2], "[^,]+") do
               table.insert(value, tonumber(token))
            end
            filter.pragmas[name].min = value[1]
            filter.pragmas[name].max = value[2]
            filter.pragmas[name].step = value[3]
            filter.pragmas[name].slider = not (value[4] == 0)

            -- Uniforms --------------------------------------------------------------------------
         elseif line:find('^[%s]*uniform') then
            line_t = line:match('[%s]*uniform[%s]*(.*)$'):gsub("[%s*=%s*]", " "):gsub (";", "")
            line_t, n = line_t:gsub("[%s]+", "#", 2)
            if n < 1 then
               print("Error in: " .. line)
               f:close()
               filter.pragmas = {}
               return cs.fallback_effect
            end
            pragma = {}
            for token in string.gmatch(line_t, "[^#]+") do
               table.insert(pragma, token)
            end
            typeof = pragma[1]
            name = pragma[2]
            value = pragma[3]
            if cs.valid_types[typeof] ~= nil then
               if filter.pragmas[name] == nil then
                  filter.pragmas[name] = {}
               end
               if cs.valid_types[typeof] == "ui" then
                  counter = counter + 1
                  filter.pragmas[name].order = counter
               end
               filter.pragmas[name].type = typeof
               if typeof == "bool" then
                  filter.pragmas[name].param = (value == "true")
               elseif typeof == "float4" then
                  num = get_vec(value, 4)
                  if num == nil then
                     num = get_vec("0.0, 0.0, 0.0, 0.0", 4)
                  end
                  filter.pragmas[name].param = num
                  filter.pragmas[name].value = obs.vec4_to_rgba(num)
               elseif typeof == "texture2d" then
                  filter.pragmas[name].value= ""
                  filter.pragmas[name].param= ""
                  filter.pragmas[name .. "_size"] = {type = "float2"}
                  filter.pragmas[name .. "_size"].param = get_vec("0,0", 2)
                  content = content .. "\n" .. "uniform float2 " .. name .. "_size={0,0};"
                  if value ~= nil then
                     local filename = filter.effect_path:match(".*/") .. value:gsub('"', "")
                     if file_exists(filename) then
                        filter.pragmas[name].value = filename
                     end
                  end
               elseif typeof == "float" or typeof == "int" then
                  filter.pragmas[name].param = value
                  if filter.pragmas[name].slider == nil then
                    filter.pragmas[name].slider = true
                  end
               elseif typeof == "float2" or typeof == "int2" then
                  filter.pragmas[name].param = get_vec(value, 2)
               elseif typeof == "float3" or typeof == "int3" then
                  filter.pragmas[name].param = get_vec(value, 3)
               elseif typeof == "int4" then
                  filter.pragmas[name].param = get_vec(value, 4)
               end
               if filter.pragmas[name].param == nil then
                  print("Missing or wrong default value in: " .. line)
                  f:close()
                  filter.pragmas = {}
                  return cs.fallback_effect              
               end
               content = content .. "\n" .. line
            end
         else
            content = content .. "\n" .. line
         end
      end
      f:close()
   end
   if cs.vertex_shader_template then
      content = content .. "\n" .. cs.effect_vertex
   end
   if cs.pixel_shader_template then
      content = content .. "\n" .. cs.effect_pixel
   end
   content = content .. "\n" .. cs.effect_bottom
   pragma = {}
   for k, v in pairs(filter.pragmas) do
      if v.type ~= nil then
         pragma[k] = v
      end
   end
   filter.pragmas = pragma
   return content
end

function load_filter(filter, settings, reload)
   local k, v, content, previous_filter

   if filter.effect ~= nil then
      destroy_filter(filter)
      filter = create_filter(filter)
   end

   if filter.effect_path == "" then
      content = cs.fallback_effect
   else
      content = read_file(filter)
   end

   obs.obs_enter_graphics()
   filter.effect = obs.gs_effect_create(content, nil, nil)
   if filter.effect == nil then
      print('Failed to load effect ' .. filter.effect_path)
      obs.obs_data_release(filter.settings)
      filter = create_filter(filter)
      filter.effect = obs.gs_effect_create(cs.fallback_effect, nil, nil)
   end

   for k, v in pairs(filter.pragmas) do
      filter.params[k] = obs.gs_effect_get_param_by_name(filter.effect, k)
      if v.type == "texture2d" then
         v.value = load_image(filter, k , v.value)
      end
      if reload and (v.order ~= nil) then
         if v.type == "float4" or v.type == "texture2d" then
            cs.set_property[v.type](filter.settings, k, v.value)
         else
            cs.set_property[v.type](filter.settings, k, v.param)
         end
      end
   end

   for k, _ in pairs( cs.params ) do
      filter.params[k] = obs.gs_effect_get_param_by_name(filter.effect, k)
   end
   obs.obs_leave_graphics()

   if reload then
      obs.obs_source_update(filter.context, filter.settings)
      obs.obs_source_update_properties(filter.context)
   else
      source_def.update(filter, settings)
   end
end

function load_image(filter, name, value)
   local image = obs.gs_image_file()
   if value == "" then
      obs.gs_image_file_init(image, cs.fallback_image)
   else
      obs.gs_image_file_init(image, value)
   end
   if not image.loaded then
      value = ""
      obs.gs_image_file_init(image, cs.fallback_image)
   end
   obs.gs_image_file_init_texture(image)
   filter.images[name] = image
   filter.pragmas[name].param = image.texture
   filter.pragmas[name .. "_size"].param = get_vec(tostring(image.cx) .. "," .. tostring(image.cy), 2)
   return value
end

function source_def.update(filter, settings)
   local k, v, value
   filter.effect_path = obs.obs_data_get_string(settings, 'effect_path')
   for k, v in pairs(filter.pragmas) do
      if v.order ~= nil then
         value = cs.get_property[v.type](settings, k)
         if v.type == "float4" then
            obs.vec4_from_rgba(filter.pragmas[k].param, value)
            filter.pragmas[k].value = value
         elseif v.type == "texture2d" then
            if value ~= v.value then
               v.value = value
               obs.obs_enter_graphics()
               obs.gs_image_file_free(filter.images[k])
               v.value = load_image(filter, k , v.value)
               obs.obs_leave_graphics()
            end
         else
            filter.pragmas[k].param = value
         end
      end
   end
end

function source_def.destroy(filter)
   destroy_filter(filter);
end

function destroy_filter(filter)
   local v
   obs.obs_enter_graphics()
   if filter.effect ~= nil then
      obs.gs_effect_destroy(filter.effect)
   end
   for _, v in pairs(filter.images) do
      obs.gs_image_file_free(v)
   end
   obs.obs_leave_graphics()
   obs.obs_data_release(filter.settings)
end

function create_filter(filter)
   filter.width = 0
   filter.height = 0
   filter.settings = obs.obs_data_create()
   filter.images = {}
   filter.pragmas = {}
   filter.params = {}
   filter.iTime = 0.0
   filter.lTime = obs.vec3()
   filter.iResolution = obs.vec2()
   math.randomseed(os.time())
   return filter
end

function source_def.create(settings, source)
   local filter = {}
   filter.context = source
   filter.effect_path = obs.obs_data_get_string(settings, 'effect_path')
   filter = create_filter(filter)
   load_filter(filter, settings, false)
   return filter
end

function source_def.get_width(filter)
   return filter.width
end

function source_def.get_height(filter)
   return filter.height
end

function source_def.video_render(filter)
   local k, v
   local filter_ok = obs.obs_source_process_filter_begin(filter.context, obs.GS_RGBA, obs.OBS_NO_DIRECT_RENDERING)
   if filter_ok then
      for k, v in pairs(filter.pragmas) do
         cs.set_effect_param[v.type](filter.params[k], filter.pragmas[k].param)
      end
      for k, v in pairs(cs.params) do
         cs.set_effect_param[v.type](filter.params[k], filter[k])
      end
      obs.obs_source_process_filter_end(filter.context, filter.effect, filter.width, filter.height)
   else
      obs.obs_source_skip_video_filter(filter.context)
   end
end

function source_def.video_tick(filter, seconds)
   local parent = obs.obs_filter_get_parent(filter.context)
   filter.width = obs.obs_source_get_base_width(parent)
   filter.height = obs.obs_source_get_base_height(parent)
   obs.vec2_set(filter.iResolution, filter.width, filter.height)

   filter.rand_f = math.random()
   filter.iTime = filter.iTime + seconds
   filter.lTime = get_vec(os.date("%H,%M,%S"), 3)
end

function source_def.get_properties(filter)
   local array, k, v, label, typeof, minval, maxval, step, def_step = {}
   local props = obs.obs_properties_create()

   obs.obs_properties_add_path(props, 'effect_path', 'Shader', obs.OBS_PATH_FILE, EFFECT_FILE_FILTER, nil)
   obs.obs_properties_add_button(props, 'reload', 'Load shader', function() load_filter(filter, filter.settings, true) end)

   for k, v in pairs(filter.pragmas) do
      if v.order ~= nil then
         table.insert(array, k)
      end
   end

   local f = function (a, b) return filter.pragmas[a].order < filter.pragmas[b].order end
   table.sort(array, f)

   for _, k in ipairs(array) do
      v = filter.pragmas[k]
      label = k:gsub("_", " "):gsub("^%l", string.upper)
      typeof = v.type
      def_step = (v.type == "int") and 1 or 0.1
      if v.slider then
        typeof = typeof .. "_slider"
      end
      minval = (v.min == nil) and -10 or v.min
      maxval = (v.max == nil) and 10 or v.max
      step = (v.step == nil) and def_step or v.step
      if typeof == "bool" then
         obs.obs_properties_add_bool(props, k, label)
      elseif typeof == "float4" then
         obs.obs_properties_add_color(props, k, label)
      elseif typeof == "texture2d" then
         obs.obs_properties_add_path(props, k, label, obs.OBS_PATH_FILE, IMAGE_FILE_FILTER, nil)
      else
         cs.add_property[typeof](props, k, label, minval, maxval, step)
      end
   end
   return props
end

function get_vec(text, size)
   local res
   if text ~= nil then
      local values, value, token = {}
      value = text:gsub('{(.-)}', "%1"):gsub('%w+%((.-)%)', "%1"):gsub("[%s]+", "")
      for token in string.gmatch(value, "[^,]+") do
         table.insert(values, tonumber(token))
      end
      if #values == size then
         if size == 2 then
            res = obs.vec2()
            obs.vec2_set(res, values[1], values[2])
         elseif size == 3 then
            res = obs.vec3()
            obs.vec3_set(res, values[1], values[2], values[3])
         elseif size == 4 then
            res = obs.vec4()
            obs.vec4_set(res, values[1], values[2], values[3], values[4])
         end
      end
   end
   return res
end

function file_exists(name)
   local f = io.open(name,"r")
   if f ~= nil then io.close(f) return true else return false end
end
