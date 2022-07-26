# Customize Firmware Fiberhome AN5506-04F 

    Modem Indihome Jadul

## Root Access via UART/Serial (First Oprek)

- Colokin aja USB TTL di board ada tandanya kok `tx,rx,gnd`
- Pass ada tulisan 'CTR-C', pencet aja. nanti masuk root shell sblm system boot
- jalankan: `telnetd -l /bin/sh`
- lalu `initialize.sh` biar proses boot berlanjut
- sekarang bisa konek root via `telnet 192.168.1.1` (autologin root tanpa password)

## Script Oprek

Sebelum jalanin script oprek, pastikan partisi sudah di **remount rw**

``` bash
# remount rw fh_extend
mount -o remount,rw /fh/extend
mount -o remount,rw /

# Change root password, but no effect.
sed -i 's/"root:.\+\?"/"root:B7AIKYar5C1XQ:0:0:root:\/:bin\/sh"/' /fs/extend/mount-fs.sh

# Root Shell on UART
sed -i 's/\/fh\/extend\/load_cli$/#&/' /fh/extend/initialize.sh

# Root Shell via telnetd
echo "telnetd -l /bin/sh" >> /fh/extend/userapp.sh

# Custom init from USB
cat <<EOF > /fh/extend/userapp.sh
#!/bin/sh
telnetd -l /bin/sh
if \$(cat /proc/diskstats | grep sda &>/dev/null); then
    echo "Found USB Storage, mount to /mnt"
    mount /dev/sda1 /mnt
    if [ -x /mnt/initialize.sh ]; then
        exec /mnt/initialize.sh
    else
        echo "Not found initialize.sh in USB Storage!"
        umount /mnt
    fi
else
    echo "initialize.sh=="
    #/fh/extend/initialize.sh
fi
EOF

```

## JIKA BRICKED

Jika mengalami salah edit filesystem sehingga linux/busybox init tidak mau booting, 
maka masih ada cara mudah untuk menanganinya. yaitu dengan boot menggunakan partisi backup/previous.
Caranya:

- Colokan USB TTL
- Nyalakan Router, pas ada prompt "Press Enter..." tekan enter 1 kali
- Anda akan masuk ke U-Boot CVE prompt. ketikan `help` untuk list command.
- ketikan `c` (Change bootline parameters)
- untuk nilai yg tidak diubah, cukup tekan `enter`
- ubah pada bagian Boot image/App basic/App extend tergantung partisi mana yg filenya problem.
- ketikan `r` untuk boot

## ftp-sync

Use sublime-text with SFTP Plugin
```
sed -i 's/^local_root\=.*/local_root=\//' /fhcfg/vsftpd.conf
killall vsftpd
mount -o remount,rw /
sed -i 's/:50:/:0:/' /etc/passwd
mount -o remount,ro /
mount -o remount,rw /fh/extend/
chmod -R g+xw /fh/extend
vsftpd &
```

## PROBLEM DRIVER

Ketika menggunakan driver bawaan tanpa custom dari fiberhome maka ada paket dhcp yg di forward.
(kemungkinan) terdapat pada custom driver wl.ko / bcm_enet.ko
jadi dhcpserver untuk client yg konek wifi gak akan dapet IP
```
test net_wlan_dhcp_pkt_filter_func-
```
## TODO
Rebuild bcm_enet.ko and/or wl.ko to make it universal

## Mounting JFFS2 Big-Endian

    Cek di folder `filesystem/*` sebelum mounting jffs2 di pc anda, mungkin file yg anda cari sudah ada disitu.

Convert JFFS2 big endian to little
```
jffs2dump -b -c -r -e mtd-little/rootfs mtd-ori/rootfs
jffs2dump -b -c -r -e mtd-little/app_extend mtd-ori/app_extend
jffs2dump -b -c -r -e mtd-little/data mtd-ori/data
```

Mount it:
```
sudo ./mount-mtd.sh mtd-little/rootfs
sudo ./mount-mtd.sh mtd-little/app_extend
sudo ./mount-mtd.sh mtd-little/data
```

## Re-Flash MTD / Recovery

Dump Partisi MTD ada di folder `mtd-ori`. Copikan ke FD, lalu mount. untuk mengembalikannya:
```
flash_eraseall /dev/mtd0
nandwrite -n -m /dev/mtd0 /mnt/mtd-ori/rootfs
flash_eraseall /dev/mtd1
nandwrite -n -m /dev/mtd1 /mnt/mtd-ori/rootfs_update
flash_eraseall /dev/mtd2
nandwrite -n -m /dev/mtd2 /mnt/mtd-ori/app_basic
flash_eraseall /dev/mtd3
nandwrite -n -m /dev/mtd3 /mnt/mtd-ori/app_basic_update
flash_eraseall /dev/mtd4
nandwrite -n -m /dev/mtd4 /mnt/mtd-ori/app_extend
flash_eraseall /dev/mtd5
nandwrite -n -m /dev/mtd5 /mnt/mtd-ori/app_extend_update
```

## LED

led 0 = off, 1 = on, 2 = blink

```
echo 1 > /sys/module/reset_led_button_drv/parameters/usb1_led_status
```
## How initialize.sh started?

Still investigating

## Customize Boot init

`/etc/init.d/bcm-base-drivers.sh` contains default SDK Driver load. but this not loaded/linked 
in /etc/rc3.d/ because the developer use custom /fh/extend/initialize.sh to load the drivers and do OEM thing.

## System Information

```
# cat /proc/cpuinfo 
system type     : AN5506-04FG
processor       : 0
cpu model       : Broadcom BMIPS4350 V8.0
BogoMIPS        : 598.01
wait instruction    : yes
microsecond timers  : yes
tlb_entries     : 32
extra interrupt vector  : no
hardware watchpoint : no
ASEs implemented    :
shadow register sets    : 1
kscratch registers  : 0
core            : 0
VCED exceptions     : not available
VCEI exceptions     : not available

processor       : 1
cpu model       : Broadcom BMIPS4350 V8.0
BogoMIPS        : 606.20
wait instruction    : yes
microsecond timers  : yes
tlb_entries     : 32
extra interrupt vector  : no
hardware watchpoint : no
ASEs implemented    :
shadow register sets    : 1
kscratch registers  : 0
core            : 0
VCED exceptions     : not available
VCEI exceptions     : not available
```

```
# cat /proc/mtd 
dev:    size   erasesize  name
mtd0: 01460000 00020000 "rootfs"
mtd1: 01460000 00020000 "rootfs_update"
mtd2: 01460000 00020000 "app_basic"
mtd3: 01460000 00020000 "app_basic_update"
mtd4: 01460000 00020000 "app_extend"
mtd5: 01460000 00020000 "app_extend_update"
mtd6: 004a0000 00020000 "data"
mtd7: 00020000 00020000 "nvram"
```

```
# mount
rootfs on / type rootfs (rw)
mtd:rootfs on / type jffs2 (ro,relatime)
proc on /proc type proc (rw,relatime)
tmpfs on /dev type tmpfs (rw,relatime)
tmpfs on /var type tmpfs (rw,relatime,size=420k)
tmpfs on /mnt type tmpfs (rw,relatime,size=16k)
sysfs on /sys type sysfs (rw,relatime)
debugfs on /sys/kernel/debug type debugfs (rw,relatime)
mtd:app_basic on /fh/bin type jffs2 (ro,relatime)
mtd:app_extend on /fh/extend type jffs2 (ro,relatime)
mtd:data on /fhcfg type jffs2 (rw,relatime)
devpts on /dev/pts type devpts (rw,relatime,mode=620,ptmxmode=000)
```

## MTD INFO
Boot with latest partition
```
Creating 8 MTD partitions on "brcmnand.0":
0x000000020000-0x000001480000 : "rootfs"
0x000001480000-0x0000028e0000 : "rootfs_update"
0x0000028e0000-0x000003d40000 : "app_basic"
0x000003d40000-0x0000051a0000 : "app_basic_update"
0x0000051a0000-0x000006600000 : "app_extend"
0x000006600000-0x000007a60000 : "app_extend_update"
0x000007a60000-0x000007f00000 : "data"
0x000000000000-0x000000020000 : "nvram"
```

Boot with backup previous partition
```
0x000001480000-0x0000028e0000 : "rootfs"
0x000000020000-0x000001480000 : "rootfs_update"
0x000003d40000-0x0000051a0000 : "app_basic"
0x0000028e0000-0x000003d40000 : "app_basic_update"
0x000006600000-0x000007a60000 : "app_extend"
0x0000051a0000-0x000006600000 : "app_extend_update"
0x000007a60000-0x000007f00000 : "data"
0x000000000000-0x000000020000 : "nvram"
```

## Modules

```
# lsmod
i2cdev 10313 0 - Live 0xc1609000 (O)
reset_led_button_drv 4792 2 - Live 0xc15fc000 (O)
misc_drv 10232 6 - Live 0xc15ef000 (O)
rdpa_cmd 100922 0 - Live 0xc15ca000
endpointdd 3835326 0 - Live 0xc11c1000 (P)
pcmshim 1354 0 - Live 0xc0ead000
wl 2921613 0 - Live 0xc0b9b000 (P)
wlemf 49862 1 wl, Live 0xc0802000 (P)
wfd 19536 1 wl, Live 0xc07e4000
pon_l2_config 4226 0 - Live 0xc07d5000 (PO)
pon_l2_driver 304375 1 pon_l2_config, Live 0xc0779000 (O)
pktrunner 19040 0 - Live 0xc071b000 (P)
bcm_enet 200340 2 wl,pon_l2_driver, Live 0xc06d2000 (O)
iomsg_drv 4146 13 i2cdev,pon_l2_driver,bcm_enet, Live 0xc067f000 (O)
laser_i2c 4777 0 - Live 0xc0676000
gpon_l2_omci_drv 35438 7 wl,pon_l2_driver,bcm_enet, Live 0xc0665000 (O)
gpon_l2_init 22199 3 pon_l2_driver,bcm_enet,gpon_l2_omci_drv, Live 0xc064f000 (O)
rdpa_upper 64544 4 pon_l2_config,pon_l2_driver,gpon_l2_omci_drv,gpon_l2_init, Live 0xc0630000 (PO)
bcmgpon 500253 0 - Live 0xc057b000 (P)
gpon_i2c 11264 0 - Live 0xc04c0000
i2c_bcm6xxx 7214 1 - Live 0xc04b4000
pktflow 111186 1 pktrunner, Live 0xc048d000 (P)
chipinfo 1277 0 - Live 0xc0466000 (P)
bcmbrfp 6814 0 - Live 0xc045f000
rdpa_mw 27896 3 rdpa_cmd,pktrunner,bcmbrfp, Live 0xc044b000
rdpa 1198092 2 pon_l2_driver,gpon_l2_init, Live 0xc02e4000 (P)
rdpa_gpl 15987 12 rdpa_cmd,wfd,pon_l2_driver,pktrunner,bcm_enet,gpon_l2_omci_drv,gpon_l2_init,rdpa_upper,bcmgpon,bcmbrfp,rdpa_mw,rdpa, Live 0xc0135000
bdmf 172809 14 rdpa_cmd,wfd,pon_l2_config,pon_l2_driver,pktrunner,bcm_enet,gpon_l2_omci_drv,gpon_l2_init,rdpa_upper,bcmgpon,bcmbrfp,rdpa_mw,rdpa,rdpa_gpl, Live 0xc00ef000
wlcsm 5156 6 - Live 0xc00a5000 (P)
```

## similar?

**DPN-124G**
GPON ONT Wireless VoIP Gateway with 1 GPON Port, 4 10/100/1000Base-T Ports, 2 FXS Ports, and 1 USB Port
http://www.dlink.lt/mn/products/1383/2177.html
**DPN-144DG**
GPON ONT Dual Band Wireless AC1200 VoIP Gateway with 1 GPON Port, 4 10/100/1000Base-T Ports, 2 FXS Ports, and 1 USB Port
http://www.dlink.lt/mn/products/1383/2176.html

https://wikidevi.wi-cat.ru/SerComm_RV6699_v2

https://wikidevi.wi-cat.ru/index.php/Special:Ask?title=Special%3AAsk&q=%3Cq%3E%5B%5BCPU1+model::~BCM68380*%5D%5D+OR+%5B%5BCPU2+model::~BCM68380*%5D%5D%3C%2Fq%3E&po=%3FEmbedded+system+type=Type%0D%0A%3FFCC+ID%0D%0A%3FManuf%0D%0A%3FManuf+product+model=Manuf.+mdl%0D%0A%3FCPU1+model=CPU1%0D%0A%3FCPU1+clock+speed%0D%0A%3FCPU2+model=CPU2%0D%0A%3FCPU2+clock+speed=CPU2+clock+speed%0D%0A%3FFLA1+amount=FLA1%0D%0A%3FFLA2+amount=FLA2%0D%0A%3FRAM1+amount=RAM1%0D%0A%3FRAM2+amount=RAM2%0D%0A%3FWI1+chip1+model=WI1+chip1%0D%0A%3FWI1+chip2+model=WI1+chip2%0D%0A%3FWI1+MIMO+config=WI1+MIMO%0D%0A%3FWI2+chip1+model=WI2+chip1%0D%0A%3FWI2+chip2+model=WI2+chip2%0D%0A%3FWI2+MIMO+config=WI2+MIMO%0D%0A%3FSupported+802dot11+protocols=PHY+modes%0D%0A%3FOUI%0D%0A%3FOUI+(ethernet)=OUI+(Eth)%0D%0A%3FEstimated+year+of+release=Est.+year&eq=yes&p%5Bformat%5D=broadtable&order%5B0%5D=ASC&sort_num=&order_num=ASC&p%5Blimit%5D=200&p%5Boffset%5D=&p%5Blink%5D=all&p%5Bsort%5D=&p%5Bheaders%5D=show&p%5Bmainlabel%5D=&p%5Bintro%5D=&p%5Boutro%5D=&p%5Bsearchlabel%5D=%E2%80%A6+further+results&p%5Bdefault%5D=&p%5Bclass%5D=sortable+wikitable+smwtable

## Possible rebuild

Firmware Source:
https://github.com/weihutaisui/BCM
make PROFILE=96838FHSFU SHELL=/bin/bash

## Reffs

PROCESSOR: bcm96838
https://github.com/paldier/rax20
https://github.com/paldier/rax200/tree/8819cdd1cec89071f496306da1b1285d9e86e837/rdp/projects/PON_6838
https://github.com/MerlinRdev/tuf-ax3000

https://github.com/minhng99/iGate_GW040/tree/master/Datasheet%20%7C%20Reference%20Design

https://github.com/search?q=bcm96838&type=Code
