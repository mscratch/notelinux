.PHONY: clean qemu

DEBIAN_RELEASE = buster

# https://nixos.wiki/wiki/Kernel_Debugging_with_QEMU
linux/arch/x86/boot/bzImage:
	cd linux && make defconfig kvm_guest.config
	cd linux && ./scripts/config --set-val DEBUG_INFO y \
		--set-val DEBUG y \
		--set-val GDB_SCRIPTS y \
		--set-val DEBUG_DRIVER y
	cd linux && yes "" | make -j`nproc`

linux/compile_commands.json:
	cd linux && ./scripts/clang-tools/gen_compile_commands.py

build: linux/arch/x86/boot/bzImage linux/compile_commands.json

# https://github.com/google/syzkaller/blob/master/docs/linux/setup_ubuntu-host_qemu-vm_x86-64-kernel.md
qemu/${DEBIAN_RELEASE}.img:
	mkdir -p qemu
	cd qemu && curl -o- https://raw.githubusercontent.com/google/syzkaller/master/tools/create-image.sh | \
		sed 's#debootstrap $$DEBOOTSTRAP_PARAMS#\0 https://mirrors.ustc.edu.cn/debian#g' | \
		bash -s -- --distribution ${DEBIAN_RELEASE}

qemu: linux/arch/x86/boot/bzImage qemu/${DEBIAN_RELEASE}.img
	cd qemu && sudo qemu-system-x86_64 \
		-m 2G \
		-smp 2 \
		-kernel ../linux/arch/x86/boot/bzImage \
		-append "console=ttyS0 root=/dev/sda earlyprintk=serial net.ifnames=0" \
		-drive file=${DEBIAN_RELEASE}.img,format=raw \
		-net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
		-net nic,model=e1000 \
		-enable-kvm \
		-nographic \
		-pidfile vm.pid \
		2>&1 | tee vm.log

clean:
	sudo rm -rv qemu
	rm -v linux/compile_commands.json
	cd linux && make mrproper
