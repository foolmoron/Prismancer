shader_type spatial;

uniform sampler2D tex : hint_default_transparent;
uniform vec4 color : source_color = vec4(1,1,1,1);
uniform float alpha_boost : hint_range(1.0, 5.0, 0.1) = 1.8;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 c = texture(tex, UV) * color;
	float a = c.a * alpha_boost;
	float whiteness = max(a - 1.0, 0.0);

	EMISSION = c.rgb + whiteness * vec3(1.0, 1.0, 1.0);
	ALPHA = a;
}