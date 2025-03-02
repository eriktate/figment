const std = @import("std");
const log = @import("../../log.zig");
const fs = std.fs;
const linux = std.os.linux;

const MAX_EVENTS = 16;

pub const EFDErr = error{
    Create,
    AddFD,
    Poll,
    MissingFile,
};

pub const File = struct {
    file: fs.File,
    ready: bool,

    pub fn read(self: *File, buf: []u8) !usize {
        if (!self.ready) {
            return 0;
        }

        const len = try self.file.read(buf);
        if (len < buf.len) {
            self.ready = false;
        }

        return len;
    }

    pub fn close(self: File) void {
        self.file.close();
    }
};

pub const FilePool = struct {
    alloc: std.mem.Allocator,
    files: std.AutoHashMap(i32, File),
    efd: i32,

    pub fn init(alloc: std.mem.Allocator) !FilePool {
        const files = std.AutoHashMap(i32, File).init(alloc);
        const efd = linux.epoll_create();
        if (efd < 0) {
            return EFDErr.Create;
        }

        return FilePool{
            .alloc = alloc,
            .files = files,
            .efd = @intCast(efd),
        };
    }

    pub fn open(self: *FilePool, path: []const u8, flags: fs.File.OpenFlags) !*File {
        const file = try fs.openFileAbsolute(path, flags);
        return try self.add(file);
    }

    pub fn add(self: *FilePool, file: fs.File) !*File {
        const event: ?*linux.epoll_event = try self.alloc.create(linux.epoll_event);
        event.?.* = linux.epoll_event{
            .events = linux.EPOLL.IN,
            .data = .{
                .fd = file.handle,
            },
        };

        if (linux.epoll_ctl(self.efd, linux.EPOLL.CTL_ADD, file.handle, event) != 0) {
            return EFDErr.AddFD;
        }

        try self.files.put(file.handle, File{
            .file = file,
            .ready = true,
        });

        return self.files.getPtr(file.handle) orelse return EFDErr.MissingFile;
    }

    pub fn read(self: *FilePool, fd: i32, buf: []u8) !usize {
        var pool_file = self.files.getPtr(fd) orelse return 0;
        if (!pool_file.ready) {
            return 0;
        }

        const len = try pool_file.file.read(buf);
        if (len < buf.len) {
            pool_file.ready = false;
        }

        return len;
    }

    pub fn close(self: FilePool) void {
        linux.close(self.efd);
        for (self.files.iterator()) |file| {
            file.close();
        }
    }

    pub fn poll(self: *FilePool) !void {
        var events: [MAX_EVENTS]linux.epoll_event = undefined;
        const res = linux.epoll_wait(self.efd, &events, MAX_EVENTS, 0);
        if (res < 0) {
            return EFDErr.Poll;
        }

        if (res == 0) {
            return;
        }

        for (0..res) |idx| {
            var pool_file = self.files.getPtr(events[idx].data.fd) orelse continue;
            pool_file.ready = true;
        }
    }
};
