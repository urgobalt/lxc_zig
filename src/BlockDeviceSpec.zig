const std = @import("std");
const LxcContainer = @import("LxcContainer.zig");
const c = LxcContainer.c;
const c_allocator = std.heap.c_allocator;

const BlockDeviceSpec = @This();

fstype: FilesystemType,
fssize: u64,
dir: [:0]const u8,
zfs: ?ZFS = null,
lvm: ?LVM = null,
rbd: ?RBD = null,

// NOTE: This part of the code is AI generated because I didn't want to look up
// exactly what filesystems lxc supports
const FilesystemType = enum {
    ext4,
    xfs,
    btrfs,
    nfs,
    fat32,
    ntfs,
    iso9660,
    udf,
    tmpfs,
    proc,
    sysfs,
    other,
};

const ZFS = struct {
    zfsroot: [:0]const u8,
};

const LVM = struct {
    vg: [:0]const u8,
    lv: [:0]const u8,
    thinpool: [:0]const u8,
};

const RBD = struct {
    rbdname: [:0]const u8,
    rbdpool: [:0]const u8,
};

pub fn intoCRepr(self: BlockDeviceSpec) c.bdev_specs {
    const fstype: []const u8 = @tagName(self.fstype);

    var spec = c.bdev_specs{ .fstype = @constCast(fstype).ptr, .fssize = self.fssize, .dir = @constCast(self.dir).ptr };

    if (self.lvm) |lvm| {
        spec.lvm.vg = @constCast(lvm.vg).ptr;
        spec.lvm.lv = @constCast(lvm.lv).ptr;
        spec.lvm.thinpool = @constCast(lvm.thinpool).ptr;
    }

    if (self.rbd) |rbd| {
        spec.rbd.rbdname = @constCast(rbd.rbdname).ptr;
        spec.rbd.rbdpool = @constCast(rbd.rbdpool).ptr;
    }

    if (self.zfs) |zfs| {
        spec.zfs.zfsroot = @constCast(zfs.zfsroot).ptr;
    }

    return spec;
}
