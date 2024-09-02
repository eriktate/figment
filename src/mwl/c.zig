const config = @import("config");

pub usingnamespace @cImport({
    @cInclude("GL/gl3w.h");
});

pub usingnamespace switch (config.platform) {
    .x11 => @cImport({
        @cInclude("EGL/egl.h");
        @cInclude("X11/Xlib.h");
        @cInclude("X11/Xutil.h");
    }),
    .win32 => @cImport({}),
    else => @compileError("unsupported platform"),
};

// pub usingnamespace @cImport({
//     @cInclude("GL/gl.h");
//     comptime {
//         switch (config.platform) {
//             inline .x11 => {
//                 @cInclude("EGL/egl.h");
//                 @cInclude("X11/Xlib.h");
//                 @cInclude("X11/Xutil.h");
//             },
//             inline else => @compileError()
//         }
//     }
// }
