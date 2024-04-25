#version 330 core

in vec2 tex_pos;
in vec4 color;

uniform sampler2D atlas;

out vec4 frag_color;

void main() {
	ivec2 tex_size = textureSize(atlas, 0);
	frag_color = texture2D(atlas, tex_pos / tex_size) * color;
}
