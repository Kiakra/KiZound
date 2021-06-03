//Copyright © 2020-2021 Mehmet Kaan Uluç <kaanuluc@protonmail.com>
//
//This software is provided 'as-is', without any express or implied
//warranty. In no event will the authors be held liable for any damages
//arising from the use of this software.
//
//Permission is granted to anyone to use this software for any purpose,
//including commercial applications, and to alter it and redistribute it
//freely, subject to the following restrictions:
//
//1. The origin of this software must not be misrepresented; you must not
//   claim that you wrote the original software. If you use this software
//   in a product, an acknowledgment in the product documentation would
//   be appreciated but is not required.
//
//2. Altered source versions must be plainly marked as such, and must not
//   be misrepresented as being the original software.
//
//3. This notice may not be removed or altered from any source
//   distribution.

const std = @import("std");
const log = std.log.scoped(.kizound_writer);

pub const WriteError = error{
    FailedToAllocateMemory,
    RequestSpace,
    NoSpaceLeft,
};

pub const Writer = std.io.Writer(*Context, WriteError, Context.write);

pub const Context = struct {
    alloc: *std.mem.Allocator = undefined,
    buffer: []u8 = undefined,
    pos: usize = undefined,

    pub fn init(alloc: *std.mem.Allocator) WriteError!Context {
        return Context{
            .alloc = alloc,
            .buffer = alloc.alloc(u8, 1) catch return WriteError.FailedToAllocateMemory,
            .pos = 0,
        };
    }

    pub fn deinit(self: Context) void {
        self.alloc.free(self.buffer);
    }

    pub fn writer(self: *Context) Writer {
        return Writer{ .context = self };
    }

    pub fn write(self: *Context, bytes: []const u8) WriteError!usize {
        if (bytes.len == 0) return 0;
        //log.debug("{}  {} ", .{ self.pos, self.buffer.len });
        const leftspace = self.buffer.len - self.pos;
        //log.debug("left:{} ", .{leftspace});

        if (leftspace < bytes.len) {
            const required = bytes.len - leftspace;
            //log.debug("required:{} ", .{required});
            self.buffer = self.alloc.realloc(self.buffer, self.buffer.len + required) catch return WriteError.FailedToAllocateMemory;
        }

        if (self.pos >= self.buffer.len) return WriteError.NoSpaceLeft;

        var i: usize = self.pos;
        var j: usize = 0;
        while (i < self.buffer.len) : (i += 1) {
            self.buffer[i] = bytes[j];
            j += 1;
        }

        self.pos = i;

        return j;
    }
};
