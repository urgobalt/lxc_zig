pub const c = @cImport({
    @cInclude("lxc/lxccontainer.h");
});

const std = @import("std");
const BlockDeviceSpec = @import("BlockDeviceSpec.zig");

const LxcContainer = @This();

inner: *c.lxc_container,

const LxcError = error{
    setupError,
    createError,
    destroyError,
    renameError,
    rebootError,
    shutdownError,
    putError,
    freezeError,
    configLoadError,
    configSaveError,
    startError,
    stopError,
    waitError,
    daemonizePreferenceChangeError,
    closeAllFileDescriptorsPreferenceChangeError,
};

pub fn new(name: [*:0]const u8, config_path: ?[*:0]const u8) !LxcContainer {
    const _container: ?*c.lxc_container = c.lxc_container_new(name, config_path orelse null);
    if (_container) |container| {
        return .{
            .inner = container,
        };
    } else {
        return error.setupError;
    }
}

fn fnType(fn_ptr: type) type {
    return switch (@typeInfo(fn_ptr)) {
        .optional => |option| option.child,
        else => @compileError("Expected an optional function pointer"),
    };
}

fn unwrapFn(fn_ptr: anytype) fnType(@TypeOf(fn_ptr)) {
    return fn_ptr orelse @panic("Null function pointer");
}

pub fn isDefined(self: LxcContainer) bool {
    return unwrapFn(self.inner.is_defined)(self.inner);
}

pub fn create(self: LxcContainer, @"type": [*:0]const u8, bdevtype: ?[*:0]const u8, specs: BlockDeviceSpec, flags: i32, argv: [:0]const [*:0]const u8) !void {
    if (!unwrapFn(self.inner.create)(self.inner, @"type", bdevtype orelse null, specs, flags, argv)) {
        return error.createError;
    }
}

pub fn destroy(self: LxcContainer) !void {
    if (!unwrapFn(self.inner.destroy)(self.inner)) {
        return error.destroyError;
    }
}

pub fn rename(self: LxcContainer, newName: [*:0]const u8) !void {
    if (!unwrapFn(self.inner.rename)(self.inner, newName)) {
        return error.renameError;
    }
}

pub fn reboot(self: LxcContainer) !void {
    if (!unwrapFn(self.inner.reboot)(self.inner)) {
        return error.rebootError;
    }
}

pub fn shutdown(self: LxcContainer, timeout: i32) !void {
    if (!unwrapFn(self.inner.shutdown)(self.inner, timeout)) {
        return error.shutdownError;
    }
}

pub const State = enum {
    Stopped,
    Starting,
    Running,
    Stopping,
    Aborting,
    Freezing,
    Frozen,
    Thawed,
    MaxState,

    const enumFields = fields: {
        switch (@typeInfo(State)) {
            .@"enum" => |_state| {
                var fields: [_state.fields.len]struct { name: [:0]const u8, value: i32 } = undefined;
                for (0.._state.fields.len) |index| {
                    const field = _state.fields[index];
                    fields[index] = .{ .name = field.name, .value = field.value };
                }
                break :fields fields;
            },
            else => @compileError("State is not an enum"),
        }
        @compileError("Unable to get fields of enum");
    };

    pub fn fromSlice(input: [*:0]const u8) ?State {
        for (enumFields) |field| {
            for (input, field.name) |lc, rc| {
                if (lc != std.ascii.toUpper(rc)) {
                    continue;
                }
            }
            return @enumFromInt(field.value);
        }
        return null;
    }
};

pub fn state(self: LxcContainer) State {
    return State.fromSlice(unwrapFn(self.inner.state)(self.inner)) orelse @panic("Divergent state in C impl for state");
}

test "state" {
    const container = try new("test", null);
    const _state = container.state();
    try std.testing.expectEqual(.Stopped, _state);
    try std.testing.expect(!container.isDefined());
}

pub fn isRunning(self: LxcContainer) bool {
    return unwrapFn(self.inner.is_running)(self.inner);
}

pub fn freeze(self: LxcContainer) !void {
    if (!unwrapFn(self.inner.freeze)(self.inner)) {
        return error.freezeError;
    }
}

pub fn unfreeze(self: LxcContainer) !void {
    if (!unwrapFn(self.inner.unfreeze)(self.inner)) {
        return error.freezeError;
    }
}

pub fn initPID(self: LxcContainer) c.pid_t {
    return unwrapFn(self.inner.init_pid)(self.inner);
}

pub fn loadConfig(self: LxcContainer, alt_file: ?[*:0]const u8) !void {
    if (!unwrapFn(self.inner.load_config)(self.inner, alt_file orelse null)) {
        return error.configLoadError;
    }
}

pub fn saveConfig(self: LxcContainer, alt_file: [*:0]const u8) !void {
    if (!unwrapFn(self.inner.load_config)(self.inner, alt_file)) {
        return error.configSaveError;
    }
}

pub fn configFileName(self: LxcContainer) ?[*:0]const u8 {
    return unwrapFn(self.inner.config_file_name)(self.inner);
}

pub fn start(self: LxcContainer, useinit: i32, argv: [][*:0]const u8) !void {
    if (!unwrapFn(self.inner.start)(self.inner, useinit, argv)) {
        return error.startError;
    }
}

pub fn stop(self: LxcContainer) !void {
    if (!unwrapFn(self.inner.stop)(self.inner)) {
        return error.stopError;
    }
}

pub fn wait(self: LxcContainer) !void {
    if (!unwrapFn(self.inner.wait)(self.inner)) {
        return error.waitError;
    }
}

pub fn wantDaemonize(self: LxcContainer, daemonState: bool) !void {
    if (!unwrapFn(self.inner.want_daemonize)(self.inner, daemonState)) {
        return error.daemonizePreferenceChangeError;
    }
}

pub fn wantCloseAllFileDescriptors(self: LxcContainer) !void {
    if (!unwrapFn(self.inner.want_close_all_fds)) {
        return error.closeAllFileDescriptorsPreferenceChangeError;
    }
}

pub fn put(self: *LxcContainer) !void {
    const res: i32 = c.lxc_container_put(self.inner);
    if (res == 0) {
        return;
    } else if (res == 1) {
        self.* = undefined;
    } else {
        return error.putError;
    }
}

test "creating and using BlockDeviceSpec" {
    const spec = BlockDeviceSpec{
        .fstype = .ext4,
        .fssize = 10 * 1024 * 1024,
        .dir = "my_dir",
    };

    _ = spec.intoCRepr();
}
