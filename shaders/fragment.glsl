#version 330 core

in vec2 tex_pos;
in vec4 color;
flat in uint tex_id;

uniform sampler2D tex_atlas;
uniform sampler2D font_atlas;
const uint TEX_UNIT = uint(0);
const uint FONT_UNIT = uint(1);

out vec4 frag_color;

void main() {
    ivec2 tex_size;
    switch (tex_id) {
        case TEX_UNIT:
        tex_size = textureSize(tex_atlas, 0);
        frag_color = texture2D(tex_atlas, tex_pos / tex_size) * color;
        break;
        case FONT_UNIT:
        tex_size = textureSize(font_atlas, 0);
        frag_color = texture2D(font_atlas, tex_pos / tex_size) * color;
        break;
    }
}
