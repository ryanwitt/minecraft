
root:
	@if [[ $$EUID -ne 0 ]]; then echo "This script must be run as root" 1>&2; exit 1; fi

upgrade: root
	yum upgrade -y
install-system-requirements: root
	yum groupinstall -y "Development tools"
	yum install -y --enablerepo=epel htop dstat git s3cmd rlwrap java7
	s3cmd --configure

install: upgrade install-system-requirements update

update: root
	curl -O https://s3.amazonaws.com/Minecraft.Download/versions/1.7.4/minecraft_server.1.7.4.jar
	install -v -b -o root -m 644 minecraft.conf /etc/init/

start: root
	tail -f /var/log/messages /var/log/minecraft.log &
	start minecraft

snapshot: root
	stop minecraft || echo server stopped already?
	sleep 1
	tar -czvf backup.`date +%Y-%m-%d-%H-%M-%S`.tgz --exclude=backup.*.tgz *
	s3cmd sync backup.*.tgz s3://minecraft.ryanwitt.com/
	start minecraft

raid:
	mdadm --verbose --create /dev/md0 --level 0 --chunk 256 --raid-devices 2 /dev/sdq /dev/sdr
	echo 'DEVICE /dev/sdq /dev/sdr' | tee /etc/mdadm.conf
	mdadm --detail --scan | tee -a /etc/mdadm.conf
	blockdev --setra 128 /dev/md0 /dev/sdq /dev/sdr
	dd if=/dev/zero of=/dev/md0 bs=512 count=1
	pvcreate /dev/md0
	vgcreate vg0 /dev/md0
	lvcreate -l+100%FREE -n world vg0
	mke2fs -t ext4 -F /dev/vg0/data

monitor:
	dstat -cdgimnprsTy --freespace
