const LxcContainer = @This();

inner: *c.lxc_container,

pub const c = @cImport({
    @cInclude("lxc/lxccontainer.h");
});

const LxcError = error{ nullFunctionPointer, setupError, putError };

pub fn new(name: [:0]const u8, config_path: ?[:0]const u8) !LxcContainer {
    const inner = inner: {
        const _container: ?*c.lxc_container = c.lxc_container_new(name, config_path orelse null);
        if (_container) |container| {
            break :inner container;
        } else {
            return error.setupError;
        }
    };

    return .{
        .inner = inner,
    };
}

pub fn is_defined(self: LxcContainer) !bool {
    return (self.inner.is_defined orelse {
        return error.nullFunctionPointer;
    })(self.inner);
}

pub fn create_list_variant(self: LxcContainer, @"type": [:0]const u8, bdevtype: [:0]const u8, bdevspecs: *c.bdev_specs, flags: [:0]const [:0]const u8) !bool {
    return (self.inner.createl orelse {
        return error.nullFunctionPointer;
    })(@"type", bdevtype, bdevspecs, flags);
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
