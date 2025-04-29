const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const test_step = b.step("test", "Run unit tests");
    const module = b.addModule("lxc-zig", .{
        .root_source_file = b.path("src/lxccontainer.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    module.linkSystemLibrary("lxc", .{
        .needed = true,
        .search_strategy = .mode_first,
    });

    const t = b.addTest(.{
        .name = "container",
        .root_module = module,
    });

    const run = b.addRunArtifact(t);
    test_step.dependOn(&run.step);
}
