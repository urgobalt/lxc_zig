const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("lxc-zig", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    module.linkSystemLibrary("lxc", .{
        .needed = true,
        .search_strategy = .mode_first,
    });

    const test_step = b.step("test", "Run unit tests");
    const container_test = container: {
        const _module = b.createModule(.{
            .root_source_file = b.path("src/LxcContainer.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });

        _module.linkSystemLibrary("lxc", .{
            .needed = true,
            .search_strategy = .mode_first,
        });

        const t = b.addTest(.{
            .name = "container",
            .root_module = _module,
        });
        break :container b.addRunArtifact(t);
    };

    test_step.dependOn(&container_test.step);
}
