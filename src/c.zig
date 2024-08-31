pub usingnamespace @cImport({
    // @cDefine("MA_NO_ENCODING", "");
    // @cDefine("MA_ENABLE_ONLY_SPECIFIC_BACKENDS", "");
    // @cDefine("MA_ENABLE_PULSEAUDIO", "");
    @cInclude("miniaudio.h");

    @cInclude("GL/gl3w.h");
    @cInclude("SDL2/SDL.h");
    @cInclude("GLFW/glfw3.h");
    @cInclude("stb_image.h");
    @cInclude("stb_truetype.h");
    @cInclude("stb_image_write.h");
});
