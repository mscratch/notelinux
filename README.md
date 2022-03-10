# Note-of-Linux

一些个人向的内核阅读笔记。

## Building

```sh
# 默认配置编译内核，生成 Compilation database
make build
# 生成 debian 镜像，并启动虚拟机
make qemu

# 启动 GDB 调试
make qemu-gdb
# 使用 gdb
make gdb
```

## TODO

[] QEMU with GDB
[] Multiarch
