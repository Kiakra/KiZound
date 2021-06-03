const std = @import("std");

fn linkLibraries(step: *std.build.LibExeObjStep, target: std.build.Target) void {
    const target_os = target.getOsTag();

    step.linkLibC();

    switch (target_os) {
        .linux => step.linkSystemLibrary("asound"),
        else => {},
    }
}

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const target = b.standardTargetOptions(.{});

    const lib = b.addStaticLibrary("kizound", "src/main.zig");
    lib.addPackagePath("kizound", "src/kizound.zig");
    linkLibraries(lib, target);
    lib.setBuildMode(mode);
    lib.install();

    var kizound_tests = b.addTest("src/kizound.zig");
    linkLibraries(kizound_tests, target);
    kizound_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&kizound_tests.step);

    const exe = b.addExecutable("kizound_main", "src/main.zig");
    exe.setTarget(target);
    exe.addPackage(lib.packages.items[0]);
    linkLibraries(exe, target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
