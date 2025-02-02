shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : hint_default_transparent;
uniform vec4 color : source_color = vec4(1,1,1,1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel of the screen.
	if (UV.x < 0.001 || UV.y < 0.001) {
		ALPHA = 0.0;
	} else {
		vec4 c = texture(tex, UV) * color;
		ALBEDO = c.rgb;
		ALPHA = c.a;
	}
}
