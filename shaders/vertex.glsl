#version 330 core

layout(location=0) in vec3 in_pos;
layout(location=1) in uvec2 in_tex_pos;
// layout(location=1) in vec2 in_tex_pos;
layout(location=2) in uvec4 in_color;

uniform uint world_width;
uniform uint world_height;
uniform mat4 projection;

out vec2 tex_pos;
out vec4 color;

void main() {
	// in_pos is based on a pixel coordinate system, so
	// we need to remap to NDC
	vec3 pos = vec3(
		(in_pos.x / world_width) * 2 - 1,
		-((in_pos.y / world_height) * 2 - 1),
		in_pos.z
	);

	// gl_Position = projection * vec4(pos, 1.0);
	gl_Position = vec4(pos, 1.0);
	tex_pos = in_tex_pos;
	color = vec4(in_color) / vec4(255, 255, 255, 255);
}
