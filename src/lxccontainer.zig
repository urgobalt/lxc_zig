const LxcContainer = @This();

inner: c.lxc_container,

pub const c = @cImport({
    @cInclude("lxc/lxccontainer.h");
});

const LxcError = error{};

pub fn new(name: []const u8, config_path: ?[]const u8) LxcContainer {}
