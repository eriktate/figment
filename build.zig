const std = @import("std");
const Backend = @import("src/mwl/mwl.zig").Backend;
const Mode = @import("src/lib.zig").Mode;
const mythic = @import("src/mythic.zig");
const native_os = @import("builtin").os.tag;

const vendor_linux_lib = "vendor/linux/lib";
const vendor_linux_include = "vendor/linux/include";
const vendor_linux_src = "vendor/linux/src";

const vendor_windows_lib = "vendor/windows/lib";
const vendor_windows_include = "vendor/windows/include";
const vendor_windows_src = "vendor/windows/src";

pub const Options = struct {
    backend: Backend = .glfw,
    mode: Mode = .editor,
    platform: mythic.Platform = mythic.getPlatformFromNative(native_os),
};

fn getTargetFromPlatform(platform: mythic.Platform) std.Target.Query {
    return switch (platform) {
        .x11 => .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
        .wayland => .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
        .win32 => .{ .cpu_arch = .x86_64, .os_tag = .windows },
        .appkit => .{ .cpu_arch = .x86_64, .os_tag = .macos },
    };
}

fn getLibFromPlatform(platform: mythic.Platform) []const u8 {
    return switch (platform) {
        .x11 => vendor_linux_lib,
        .win32 => vendor_windows_lib,
        else => "",
    };
}

fn getIncludeFromPlatform(platform: mythic.Platform) []const u8 {
    return switch (platform) {
        .x11 => vendor_linux_include,
        .win32 => vendor_windows_include,
        else => "",
    };
}

fn getSrcFromPlatform(platform: mythic.Platform) []const u8 {
    return switch (platform) {
        .x11 => vendor_linux_src,
        .win32 => vendor_windows_src,
        else => "",
    };
}
// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const defaults = Options{};
    const build_opts = Options{
        .backend = b.option(Backend, "backend", "windowing and input backend to use (default: mwl, glfw, sdl)") orelse defaults.backend,
        .mode = b.option(Mode, "mode", "mode that the exe should start up in (default: editor, pipeline, game)") orelse defaults.mode,
        .platform = b.option(mythic.Platform, "platform", "platform that should be built against, which also defines the windowing system used (default: <detected>, x11, wayland, win32, appkit)") orelse defaults.platform,
    };
    const options = b.addOptions();

    options.addOption(Options, "opts", build_opts);

    const vendor_lib = getLibFromPlatform(build_opts.platform);
    const vendor_include = getIncludeFromPlatform(build_opts.platform);
    const vendor_src = getSrcFromPlatform(build_opts.platform);

    // This is a weird hack because specifying the target explicitly for native linux seems
    // to lose the system include path. Adding all required headers to the vendor/include/
    // directory is a possible fix for this if we can't figure out why this happens
    const target = switch (build_opts.platform) {
        mythic.getPlatformFromNative(native_os) => b.standardTargetOptions(.{}),
        else => b.resolveTargetQuery(getTargetFromPlatform(build_opts.platform)),
    };

    const optimize = b.standardOptimizeOption(.{});

    const options_mod = options.createModule();
    const c_mod = b.addModule("c", .{
        .root_source_file = b.path("src/c/c.zig"),
        .target = target,
        .optimize = optimize,
    });
    c_mod.addImport("config", options_mod);
    c_mod.addIncludePath(b.path(vendor_include));
    c_mod.addLibraryPath(b.path(vendor_lib));
    c_mod.addCSourceFile(.{
        .file = b.path("src/impl.c"),
        .flags = &.{},
    });

    c_mod.addCSourceFile(.{
        .file = b.path(b.pathJoin(&.{ vendor_src, "/gl3w.c" })),
        .flags = &.{},
    });

    if (build_opts.platform == .x11 and build_opts.backend == .mwl) {
        c_mod.linkSystemLibrary("X11", .{});
        c_mod.linkSystemLibrary("EGL", .{});
    }

    if (build_opts.platform == .x11 or build_opts.platform == .wayland) {
        c_mod.linkSystemLibrary("pthread", .{});
        c_mod.linkSystemLibrary("m", .{});
    }

    if (build_opts.platform == .win32) {
        // TODO (soggy): figure out if all of these are needed
        c_mod.linkSystemLibrary("opengl32", .{});
        c_mod.linkSystemLibrary("gdi32", .{});
        c_mod.linkSystemLibrary("user32", .{});
        c_mod.linkSystemLibrary("kernel32", .{});
    }

    c_mod.linkSystemLibrary("glfw3", .{});

    const exe = b.addExecutable(.{
        .name = "mythic",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibC();
    exe.root_module.addImport("config", options_mod);
    exe.root_module.addImport("c", c_mod);

    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
