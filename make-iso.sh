# Docs:
# - https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls
# - https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls/ConfigReference
# - https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html
# - https://discourse.ubuntu.com/t/please-test-autoinstalls-for-20-04/15250/53

if [ -d 'iso' ]; then
  rm -rf iso
fi

# Create ISO distribution dirrectory:
mkdir -p iso/nocloud/

if [ ! -f 'ubuntu-20.04.1-live-server-amd64.iso' ]; then
  wget --limit-rate 2500k https://releases.ubuntu.com/20.04/ubuntu-20.04.1-live-server-amd64.iso
fi
EXPECTED_HASH="$( sha256sum ubuntu-20.04.1-live-server-amd64.iso )"
rm -rf SHA256SUMS
wget https://releases.ubuntu.com/20.04/SHA256SUMS
ACTUAL_HASH="$( grep ubuntu-20.04.1-live-server-amd64.iso SHA256SUMS | tr '*' ' ')"
if [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then
  rm ubuntu-20.04.1-live-server-amd64.iso
  echo "$EXPECTED_HASH"
  echo "Does not equal"
  echo "$ACTUAL_HASH"
  exit 1
fi

# Extract ISO:
7z x ubuntu-20.04.1-live-server-amd64.iso -oiso

# Create empty meta-data file:
touch iso/nocloud/meta-data

# Copy user-data file:
cp user-data iso/nocloud/user-data

mkdir -p iso/root-scripts/
cp test.sh iso/root-scripts/
cp take-user-input.service iso/root-scripts/
chmod +x iso/root-scripts/*.sh

# Remove BOOT directory:
rm -rf 'iso/[BOOT]/'

# Disable mandatory md5 checksum on boot:
md5sum iso/README.diskdefines > iso/md5sum.txt
sed -i 's|iso/|./|g' iso/md5sum.txt

# Update boot flags with cloud-init autoinstall:
## Should look similar to this: initrd=/casper/initrd quiet autoinstall ds=nocloud;s=/cdrom/nocloud/ ---
sed -i 's|---|autoinstall ds=nocloud\\\;s=/cdrom/nocloud/ ---|g' iso/boot/grub/grub.cfg
sed -i 's|---|autoinstall ds=nocloud;s=/cdrom/nocloud/ ---|g' iso/isolinux/txt.cfg

# Create Install ISO from extracted dir (ArchLinux):
sudo apt install xorriso
sudo apt-get install isolinux
xorriso -as mkisofs -r \
  -V Ubuntu\ custom\ amd64 \
  -o ubuntu-20.04.1-live-server-amd64-autoinstall.iso \
  -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -isohybrid-gpt-basdat -isohybrid-apm-hfsplus \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin  \
  iso/boot iso

# After install:
# - login with 'root:root' and change root user password
# - set correct hostname with 'hostnamectl'
