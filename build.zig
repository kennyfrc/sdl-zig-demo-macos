const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "sdl-zig-demo",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    if (target.result.os.tag == .macos) {
        exe.addIncludePath("/opt/homebrew/include/SDL2");
        exe.linkSystemLibrary("SDL2");
        exe.linkFramework("CoreVideo");
        exe.linkFramework("CoreAudio");
        exe.linkFramework("AudioToolbox");
    } else if (target.result.os.tag == .linux) {
        exe.linkSystemLibrary("SDL2");
        exe.linkLibC();
    } else {
        @panic("Unsupported OS");
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the demo");
    run_step.dependOn(&run_cmd.step);
}
