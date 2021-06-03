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

    /// snd_sterror
    pub fn strerror(errnum: i32) ?[]const u8 {
        const dat = snd_strerror(errnum);
        if (dat) |data|
            return std.mem.spanZ(data);
        return null;
    }

    pub const pcm = struct {
        pub const t = c.snd_pcm_t;
        pub const hw_params_t = c.snd_pcm_hw_params_t;
        pub const sw_params_t = c.snd_pcm_sw_params_t;

        pub const stream = extern enum(c_int) {
            playback,
            capture,
        };

        pub const nonblock = c.SND_PCM_NONBLOCK;

        /// snd_pcm_open
        pub fn open(pcmp: **t, name: ?[]const u8, st: stream, mode: i32) i32 {
            return snd_pcm_open(
                pcmp,
                if (name) |data| @ptrCast([*c]const u8, data) else null,
                st,
                mode,
            );
        }

        /// snd_pcm_close
        pub fn close(pcmp: *t) i32 {
            return snd_pcm_close(pcmp);
        }

        /// snd_pcm_hw_params_sizeof
        pub fn hw_params_sizeof() usize {
            return snd_pcm_hw_params_sizeof();
        }

        /// snd_pcm_hw_params_alloca
        pub fn hw_params_alloca(hw: **hw_params_t) void {
            @compileError("does not implemented");
            return c.snd_pcm_hw_params_alloca(hw);
        }

        /// snd_pcm_hw_params
        pub fn hw_params(pcmp: *t, hw: *hw_params_t) i32 {
            return snd_pcm_hw_params(pcmp, hw);
        }
    };
};

extern fn snd_strerror(errnum: c_int) [*c]const u8;

extern fn snd_pcm_open(pcmp: ?**snd.pcm.t, name: [*c]const u8, stream: snd.pcm.stream, mode: c_int) c_int;
extern fn snd_pcm_close(pcmp: ?*snd.pcm.t) c_int;

extern fn snd_pcm_hw_params_sizeof() c_ulong;
extern fn snd_pcm_hw_params(pcmp: ?*snd.pcm.t, params: ?*snd.pcm.hw_params_t) c_int;
