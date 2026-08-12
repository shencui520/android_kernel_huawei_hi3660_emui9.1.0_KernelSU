# Hi3660 Linux Server Runtime

这是配套 `linux-server-optimization` 内核分支的 KernelSU 模块。它不会替换
KernelSU，也不会自动下载系统镜像。模块负责四件事：

1. 仅在 Docker 或 Linux 系统容器运行时持有 `hi3660_linux_server` wake lock；
2. 用 ext4 Loop 镜像保存 Docker `overlay2` 和 Linux rootfs；
3. 把 Android 已有的 cgroup v1 控制器整理到统一层级；
4. 在独立 PID/Mount/UTS/IPC namespace 中启动 Debian/Ubuntu 的 `/sbin/init`。

## 准备

目前 Docker 仍以现有的 permissive 方案运行。先在 Termux 安装模块依赖：

```sh
pkg install e2fsprogs util-linux tar
```

还需要已有的 `dockerd`、Docker CLI 和上游 `runc`。如果它们不在 PATH，编辑：

```text
/data/adb/hi3660-server/server.conf
```

设置 `DOCKERD_BIN`、`DOCKER_BIN` 和 `RUNC_BIN` 的绝对路径。

## 首次初始化

所有命令都以 root 执行：

```sh
CTL=/data/adb/modules/hi3660_linux_server/bin/serverctl
su -c "$CTL validate"
su -c "$CTL init-storage 8192"
su -c "$CTL mount-storage"
su -c "$CTL docker-start"
su -c "$CTL status"
```

`init-storage` 只允许显式执行一次，默认预分配 8 GiB，避免运行中因 `/data`
空间耗尽而损坏 ext4。需要稀疏文件时先把 `PREALLOCATE_STORAGE=0`，但不建议长期
服务器使用。镜像位置是 `/data/adb/hi3660-server/server-data.ext4`，挂载点是
`/data/local/linux-server`。

Docker 守护进程使用：

- ext4 上的 `overlay2`；
- `cgroupfs` 和 cgroup v1；
- `runc-upstream`；
- 轮转后的 `json-file` 日志；
- 默认关闭 bridge、iptables 和 NAT。

容器先用 host 网络：

```sh
su -c 'docker run --rm --network host alpine uname -a'
```

## Debian/Ubuntu 系统容器

准备 arm64 rootfs tar 包，复制到手机后导入。目标目录非空时命令会拒绝覆盖。
由于本机是 4.9 内核，优先选择 Debian 11 或 Ubuntu 20.04；Debian 12 / Ubuntu
22.04 可以测试，但其中部分服务假定至少 4.15 内核，不承诺全部可用：

```sh
su -c "$CTL import-rootfs /sdcard/Download/debian-arm64-rootfs.tar.xz"
su -c "$CTL linux-start"
su -c "$CTL status"
```

系统容器共享 Android 网络，但有独立的 PID、Mount、UTS、IPC namespace，并把
统一后的 cgroup v1 层级挂载到 `/sys/fs/cgroup`。确认系统可正常关机后，再在
`server.conf` 设置：

```sh
AUTO_START_LINUX=1
AUTO_RESTART_LINUX=1
```

模块为 systemd 建立额外的 `name=systemd` cgroup v1 层级。较新 systemd 对
cgroup v1 的支持属于兼容模式；不要在这台 4.9 内核设备上启用依赖 user
namespace 的 rootless 容器。

## 运维

```sh
su -c "$CTL cgroup-status"
su -c "$CTL logs 200"
su -c "$CTL linux-stop"
su -c "$CTL docker-stop"
su -c "$CTL shutdown"
```

卸载模块不会删除 `/data/adb/hi3660-server`、Docker 数据或 Linux rootfs。
