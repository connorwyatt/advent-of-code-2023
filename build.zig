const std = @import("std");
const Build = std.Build;
const CompileStep = std.Build.Step.Compile;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const install_all_step = b.step("install_all", "Install all days");
    const run_all_step = b.step("run_all", "Run all days");
    const test_all_step = b.step("test_all", "Test all days");

    var day_number: u8 = 1;
    while (day_number <= 25) : (day_number += 1) {
        const day_string = b.fmt("day-{:0>2}", .{day_number});

        var part_number: u8 = 1;
        while (part_number <= 2) : (part_number += 1) {
            const part_string = b.fmt("part-{}", .{part_number});
            const day_and_part_string = b.fmt("{s}-{s}", .{ day_string, part_string });

            const zig_file = b.fmt("src/{s}/{s}.zig", .{ day_string, part_string });

            _ = std.fs.cwd().statFile(zig_file) catch continue;

            const exe = b.addExecutable(.{
                .name = day_string,
                .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = zig_file } },
                .target = target,
                .optimize = mode,
            });

            const install_cmd = b.addInstallArtifact(exe, .{});

            const build_test = b.addTest(.{
                .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = zig_file } },
                .target = target,
                .optimize = mode,
            });

            const run_test = b.addRunArtifact(build_test);

            {
                const step_key = b.fmt("install_{s}", .{day_and_part_string});
                const step_desc = b.fmt("Install {s}", .{day_and_part_string});
                const install_step = b.step(step_key, step_desc);
                install_step.dependOn(&install_cmd.step);
                install_all_step.dependOn(&install_cmd.step);
            }

            {
                const step_key = b.fmt("test_{s}", .{day_and_part_string});
                const step_desc = b.fmt("Run tests in {s}", .{day_and_part_string});
                const test_step = b.step(step_key, step_desc);
                test_step.dependOn(&run_test.step);
                test_all_step.dependOn(&run_test.step);
            }

            const run_cmd = b.addRunArtifact(exe);
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }

            const run_key = b.fmt("run_{s}", .{day_and_part_string});
            const run_desc = b.fmt("Run {s}", .{day_and_part_string});
            const run_step = b.step(run_key, run_desc);
            run_step.dependOn(&run_cmd.step);
            run_all_step.dependOn(&run_cmd.step);
        }
    }
}
