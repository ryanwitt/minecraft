
root:
	@if [[ $$EUID -ne 0 ]]; then echo "This script must be run as root" 1>&2; exit 1; fi

upgrade: root
	yum upgrade -y
install-system-requirements: root
	yum groupinstall -y "Development tools"
	yum install -y --enablerepo=epel htop dstat git s3cmd rlwrap

install: upgrade install-system-requirements update

update: root
	curl -O https://s3.amazonaws.com/Minecraft.Download/versions/1.7.4/minecraft_server.1.7.4.jar
	install -v -b -o root -m 644 minecraft.conf /etc/init/

start: root
	tail -f /var/log/messages /var/log/minecraft.log &
	start minecraft

raid:
	mdadm --verbose --create /dev/md0 --level 0 --chunk 256 --raid-devices 2 /dev/sdb
	exit
	echo 'DEVICE $(DEVICES)' | tee /etc/mdadm.conf
	mdadm --detail --scan | tee -a /etc/mdadm.conf
	blockdev --setra 128 /dev/md0
	for dev in $(DEVICES); do blockdev --setra 128 $$dev; done
	dd if=/dev/zero of=/dev/md0 bs=512 count=1
	pvcreate /dev/md0
	vgcreate vg0 /dev/md0
	lvcreate -l 90%vg -n data vg0
	lvcreate -l 5%vg -n log vg0
	lvcreate -l 5%vg -n journal vg0
	mke2fs -t ext4 -F /dev/vg0/data

monitor:
	dstat -cdgimnprsTy --freespace
