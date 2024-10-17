const config = @import("config");

pub usingnamespace switch (config.opts.platform) {
    .x11 => x11(),
    .win32 => win32{},
    else => @compileError("unsupported platform"),
};

fn x11() type {
    return @cImport({
        // @cDefine("MA_NO_ENCODING", "");
        // @cDefine("MA_ENABLE_ONLY_SPECIFIC_BACKENDS", "");
        // @cDefine("MA_ENABLE_PULSEAUDIO", "");
        @cInclude("miniaudio.h");

        @cInclude("GL/gl3w.h");
        @cInclude("EGL/egl.h");
        @cInclude("X11/Xlib.h");
        @cInclude("X11/Xutil.h");
        @cInclude("SDL2/SDL.h");
        @cInclude("GLFW/glfw3.h");
        @cInclude("stb_image.h");
        @cInclude("stb_truetype.h");
        @cInclude("stb_image_write.h");
    });
}

fn win32() type {
    return @cImport({
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
}
