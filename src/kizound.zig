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

pub const alsa = @import("native/alsalib.zig");

test "Alsa pcm open" {
    const device = "hw:1,0";
    var handle: *alsa.snd.pcm.t = undefined;

    try testing.expect(0 == alsa.snd.pcm.open(&handle, device, .playback, 0));
}

test "Writer" {
    const writer = @import("writer.zig");

    var context = try writer.Context.init(testing.allocator);
    defer context.deinit();

    var w = context.writer();
    // returns the number of bytes has written
    const n = try w.write("Hello World!");

    try testing.expect(n == std.mem.len("Hello World!"));
}
