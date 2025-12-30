shader_type canvas_item;

uniform vec2 node_scale = vec2(2.0,2.0);
uniform vec4 mix_color : source_color;
uniform vec4 sample_color : source_color;

void fragment(){
  vec4 current_pixel = texture(TEXTURE, UV * node_scale);
  vec4 relative_pixel = abs(current_pixel - sample_color);
  float relative_pixel_max = max(max(relative_pixel.r, relative_pixel.g), relative_pixel.b);
  if(relative_pixel_max < 0.8){
    COLOR = mix_color;
  }else{
    COLOR = current_pixel;
  }
}