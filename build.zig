const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const run_exe = exe: {
        const module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });

        module.linkSystemLibrary("lxc", .{
            .needed = true,
        });

        const exe = b.addExecutable(.{ .name = "lxc-zig", .root_module = module });

        b.installArtifact(exe);

        break :exe b.addRunArtifact(exe);
    };

    const run_step = b.step("run", "Run the lxc binary immediatly after building");
    run_step.dependOn(&run_exe.step);
}
