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
const c = @import("c.zig");

pub const snd = struct {
    /// log.crit({first}: {result});
    pub fn check(log: anytype, first: []const u8, result: i32) void {
        log.crit("{s}: {s}", .{ first, snd.strerror(result) });
    }

    extern fn snd_strerror(errnum: c_int) [*c]const u8;
    /// snd_sterror
    pub fn strerror(errnum: i32) ?[]const u8 {
        const dat = snd_strerror(errnum);
        if (dat) |data|
            return std.mem.spanZ(data);
        return null;
    }

    pub const pcm = struct {
        pub const t = extern opaque {};
        pub const stream = extern enum(c_int) {
            playback,
            capture,
        };

        pub const nonblock = c.SND_PCM_NONBLOCK;

        extern fn snd_pcm_open(pcmp: ?**snd.pcm.t, name: [*c]const u8, stream: snd.pcm.stream, mode: c_int) c_int;
        /// snd_pcm_open
        pub fn open(pcmp: **t, name: ?[]const u8, st: stream, mode: i32) i32 {
            return snd_pcm_open(
                pcmp,
                if (name) |data| @ptrCast([*c]const u8, data) else null,
                st,
                mode,
            );
        }
    };
};
