shader_type spatial;

uniform sampler2D tex : hint_default_transparent;
uniform vec4 color : source_color = vec4(1,1,1,1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel of the screen.
	vec4 c = texture(tex, UV) * color;
	EMISSION = c.rgb;
	ALPHA = c.a;
}