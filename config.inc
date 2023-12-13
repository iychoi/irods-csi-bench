#!/bin/bash

export K3S_VERSION=v1.23.5+k3s1

export BENCHMARK_IMAGE=cyverse/fs_bench:v0.1

# irodsfs
export IRODS_HOST=data.cyverse.org
export IRODS_PORT=1247
export IRODS_ZONE=iplant
export IRODS_USER=
export IRODS_PASSWORD=

export IRODSFS_PV_NAME=irodsfs-pv
export IRODSFS_PVC_NAME=irodsfs-pvc
export IRODSFS_PV_ID=irodsfs-volid

export IRODSFS_OVERLAYFS_PV_NAME=irodsfs-overlayfs-pv
export IRODSFS_OVERLAYFS_PVC_NAME=irodsfs-overlayfs-pvc
export IRODSFS_OVERLAYFS_PV_ID=irodsfs-overlayfs-volid

export IRODSFS_FUSEOVERLAYFS_PV_NAME=irodsfs-fuseoverlayfs-pv
export IRODSFS_FUSEOVERLAYFS_PVC_NAME=irodsfs-fuseoverlayfs-pvc
export IRODSFS_FUSEOVERLAYFS_PV_ID=irodsfs-fuseoverlayfs-volid

# iozone
export IOZONE_NAME=irodsfs-iozone
export IOZONE_OVERLAYFS_NAME=irodsfs-overlayfs-iozone
export IOZONE_FUSEOVERLAYFS_NAME=irodsfs-fuseoverlayfs-iozone

# git
export GIT_NAME=irodsfs-git
export GIT_OVERLAYFS_NAME=irodsfs-overlayfs-git
export GIT_FUSEOVERLAYFS_NAME=irodsfs-fuseoverlayfs-git

