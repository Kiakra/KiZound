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
const testing = std.testing;

usingnamespace @import("kizound").alsa;

const tlog = std.log.scoped(.kizound_main);

pub fn main() !void {
    var alloc = testing.allocator;
    const device = "hw:1,0";
    var handle: *snd.pcm.t = undefined;

    // align
    const size = snd.pcm.hw_params_sizeof();
    var hw_params_ptr = blk: {
        var ret = try alloc.allocAdvanced(u8, 16, size, .exact);
        for (ret) |*ch| {
            ch.* = 0;
        }
        break :blk ret;
    };
    var hw_params = @ptrCast(*snd.pcm.hw_params_t, hw_params_ptr);
    defer alloc.free(hw_params_ptr);

    snd.check(tlog, "pcm open", snd.pcm.open(&handle, device, .playback, 0));
    defer snd.check(tlog, "pcm close", snd.pcm.close(handle));

    snd.check(tlog, "pcm hw params", snd.pcm.hw_params(handle, hw_params));
}
