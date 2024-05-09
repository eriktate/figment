#version 330 core

in vec2 tex_pos;
in vec4 color;

uniform sampler2D atlas;

out vec4 frag_color;

void main() {
	ivec2 tex_size = textureSize(atlas, 0);
	// vec2 tex_size = vec2(1024, 1024);
	// vec2 pos = vec2(tex_pos.x / tex_size.x, tex_pos.y / tex_size.y);
	// vec2 pos = vec2(tex_pos.x / 1024, tex_pos.y / 1024);
	frag_color = texture2D(atlas, tex_pos / tex_size) * color;
	// frag_color = texture2D(atlas, pos) * color;
}
