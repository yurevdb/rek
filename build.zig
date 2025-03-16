const std = @import("std");

//const targets = [_]std.zig.CrossTarget{
//    .{ .cpu_arch = .aarch64, .os_tag = .linux },
//    .{ .cpu_arch = .aarch64, .os_tag = .macos },
//    .{ .cpu_arch = .aarch64, .os_tag = .windows },
//};

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const root_file_path = b.path("src/main.zig");

    const exe_mod = b.createModule(.{
        .root_source_file = root_file_path,
        .target = b.standardTargetOptions(.{}),
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{
        .name = "rek",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/tests.zig"),
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unitests");
    test_step.dependOn(&run_exe_unit_tests.step);

    //const exe_step = b.step("exe", "Install executable for all targets");
    //for (targets) |target| {
    //    const build_exe = b.addExecutable(.{
    //        .name = "rek",
    //        .target = target,
    //        .optimize = optimize,
    //        .root_source_file = root_file_path,
    //    });
    //    const exe_install = b.addInstallArtifact(build_exe, .{});
    //    exe_step.dependOn(&exe_install.step);
    //}
    //b.default_step.dependOn(exe_step);
}
