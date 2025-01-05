shader_type spatial;

render_mode unshaded, cull_disabled;

group_uniforms shield_parameters;

/** Color to use when rendering the shield */
uniform vec4 color: source_color;

/** How sharp the shield's outline is */
uniform float fresnel_sharpness = 1.0;

/** Distance to extend the shield out from each vertex */
uniform float extend_distance = 0.0;

group_uniforms impact_parameters;

/**
 * How many impacts can be tracked by the shader.
 * This should match the length of `impact_points` array that is passed in.
 */
const int impacts_tracked = 16;

/**
 * List of impact locations (xyz) and their age (w).
 * Age must be updated outside of the shader and passed in each frame.
 */
uniform vec4 impact_points[impacts_tracked];

/**
 * Size of the impacts.
 * This is used to determine how far the impact wave will expand.
 *
 * Possible improvement: switch this to an array to change the size of each impact.
 */
uniform float impact_size = 0.25;

/** How sharply the impact wave will expand and fade */
uniform float impact_falloff_sharpness = 1.0;

/** Position of the vertex in local space */
varying vec3 local_pos;

void vertex() {
	// Extend the vertex position along its normal
	VERTEX += NORMAL * extend_distance;
	local_pos = VERTEX;
}

/**
 * Remap  a number from one range to another.
 */
float remap(float num, float a1, float a2, float b1, float b2) {
	return b1 + (num - a1) * (b2 - b1) / (a2 - a1);
}

void fragment() {
	float wave_intensity = 0.0;
	for (int i = 0; i < impacts_tracked; i++) {
		// as impact age goes from 1 to 0, inv_time goes from 0 to 1
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

		// use impact age to make the wave fade over time
		wave_intensity += wave_shape * pow(impact_points[i].w, impact_falloff_sharpness);
	}

	float fresnel = pow(-dot(VIEW, NORMAL) + 1.0, fresnel_sharpness);

	ALBEDO.rgb = color.rgb;

	// clamp the wave intensity so overlapping waves and fresnel edge dont have an intensity > 1
	ALPHA = clamp(wave_intensity + fresnel, 0.0, 1.0) * color.a;
}
