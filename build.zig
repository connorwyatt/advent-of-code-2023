const std = @import("std");
const Build = std.Build;
const CompileStep = std.Build.Step.Compile;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const install_all_step = b.step("install_all", "Install all days");
    const run_all_step = b.step("run_all", "Run all days");
    const test_all_step = b.step("test_all", "Test all days");

    var dayNumber: u8 = 1;
    while (dayNumber <= 25) : (dayNumber += 1) {
        const dayNumberString = b.fmt("{:0>2}", .{dayNumber});
        const dayString = b.fmt("day-{s}", .{dayNumberString});
        const zigFile = b.fmt("src/{s}/main.zig", .{dayString});

        _ = std.fs.cwd().statFile(zigFile) catch continue;

        const exe = b.addExecutable(.{
            .name = dayString,
            .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = zigFile } },
            .target = target,
            .optimize = mode,
        });

        const install_cmd = b.addInstallArtifact(exe, .{});

        const build_test = b.addTest(.{
            .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = zigFile } },
            .target = target,
            .optimize = mode,
        });

        const run_test = b.addRunArtifact(build_test);

        {
            const step_key = b.fmt("install_{s}", .{dayString});
            const step_desc = b.fmt("Install {s}", .{dayString});
            const install_step = b.step(step_key, step_desc);
            install_step.dependOn(&install_cmd.step);
            install_all_step.dependOn(&install_cmd.step);
        }

        {
            const step_key = b.fmt("test_{s}", .{dayString});
            const step_desc = b.fmt("Run tests in {s}", .{dayString});
            const test_step = b.step(step_key, step_desc);
            test_step.dependOn(&run_test.step);
            test_all_step.dependOn(&run_test.step);
        }

        const run_cmd = b.addRunArtifact(exe);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_key = b.fmt("run_{s}", .{dayString});
        const run_desc = b.fmt("Run {s}", .{dayString});
        const run_step = b.step(run_key, run_desc);
        run_step.dependOn(&run_cmd.step);
        run_all_step.dependOn(&run_cmd.step);
    }
}
