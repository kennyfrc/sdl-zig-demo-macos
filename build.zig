const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "sdl-zig-demo",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    if (target.isNativeOs()) {
        if (target.getOsTag() == .linux) {
            // The SDL package doesn't work for Linux yet, so we rely on system
            // packages for now.
            exe.linkSystemLibrary("SDL2");
            exe.linkLibC();
        } else if (target.getOsTag() == .macos) {
            exe.addIncludeDir("/opt/homebrew/include/SDL2");
            exe.linkSystemLibrary("SDL2");
            exe.linkFramework("CoreVideo");
            exe.linkFramework("CoreAudio");
            exe.linkFramework("AudioToolbox");
        } else {
            const sdl_dep = b.dependency("sdl", .{
                .optimize = .ReleaseFast,
                .target = target,
            });
            exe.linkLibrary(sdl_dep.artifact("SDL2"));
        }
    } else {
        const sdl_dep = b.dependency("sdl", .{
            .optimize = .ReleaseFast,
            .target = target,
        });
        exe.linkLibrary(sdl_dep.artifact("SDL2"));
    }

    b.installArtifact(exe);

    const run = b.step("run", "Run the demo");
    const run_cmd = b.addRunArtifact(exe);
    run.dependOn(&run_cmd.step);
}
