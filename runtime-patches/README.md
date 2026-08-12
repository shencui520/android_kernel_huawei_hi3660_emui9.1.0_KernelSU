# Android container runtime patches

`containerd-1.7.3-android-cgroup-root.diff` fixes cgroup v1 discovery in the runc v2 shim. EMUI mounts Android aliases such as `/acct` before the Docker-compatible split hierarchy at `/sys/fs/cgroup`; upstream containerd/cgroups otherwise chooses `/` as its controller root and reports every Docker cgroup as deleted.

The patch is intentionally limited to containerd 1.7.3 and is built by `build_android_containerd.yml`. Kernel builds do not consume these files.
