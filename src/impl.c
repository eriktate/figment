#define MA_NO_ENCODING
#define MA_ENABLE_SPECIFIC_BACKENDS
#define MA_ENABLE_PULSEAUDIO
#define MA_NO_MP3
#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG
// #define STBI_NO_STDIO
#include "stb_image.h"

#define STB_TRUETYPE_IMPLEMENTATION
#include "stb_truetype.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
