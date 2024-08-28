shader_type spatial;

render_mode unshaded;

group_uniforms shield_parameters;
uniform vec4 color : source_color;
uniform float fresnel_sharpness = 1.0;

group_uniforms impact_parameters;
// this defines how many simultaneous impacts the shader will track
const int impacts_tracked = 16;
// information about impact locations (xyz) and their age (w)
uniform vec4 impact_points[impacts_tracked];
// determines the size of the impacts
// note that you could pass in an array here as well to determine impact size on a per-impact basis
uniform float impact_size;
// determines how sharply to curve the impacts expansion and fading
uniform float impact_falloff_sharpness = 1.0;

// used to get the fragment position in object space without doing view matrix math
varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX;
}

float remap(float num, float a1, float a2, float b1, float b2) {
	return b1 + (num - a1) * (b2 - b1) / (a2 - a1);
}

void fragment() {
	float wave_intensity = 0.0;
	for (int i = 0; i < impacts_tracked; i ++) {
		// as impact_points[i].w goes from 1 to 0, inv_time goes from 0 to 1
		float inv_time = remap(pow(impact_points[i].w, impact_falloff_sharpness), 1, 0, 0.01, 0.99);
		
		// we use inv_time here to make the wave expand over time rather than contract
		float distance_to_impact = distance(local_pos, impact_points[i].xyz) / (inv_time * impact_size);
		
		// default linear gradient
		//float wave_shape = max(0, 1.0 - distance_to_impact);
		
		// sine donut with sharpening
		//float sharpness = 1.0;
		//float wave_shape = pow(sin(clamp(distance_to_impact / impact_size, 0, PI)), sharpness);
		
		// sawtooth donut with sharpening
		float sharpness = 5.0;
		float wave_shape = pow(fract(max(0, 1.0 - distance_to_impact) * -1.0), sharpness);
		
		// we use impact_points[i].w here to make the wave fade over time
		wave_intensity += wave_shape * pow(impact_points[i].w, impact_falloff_sharpness);
	}
	
	float fresnel = pow(-dot(VIEW, NORMAL) + 1.0, fresnel_sharpness);
	
	ALBEDO.rgb = color.rgb;
	// clamp the wave intensity so overlapping waves and fresnel edge dont have an intensity > 1
	ALPHA = clamp(wave_intensity + fresnel, 0, 1);
}