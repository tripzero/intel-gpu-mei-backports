set -ex

sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf install -y dkms kernel-devel kernel-core

(
cd output/cse
sudo rpm -i intel-platform-cse-*.rpm --noscripts
)

ls -t /usr/src
cse_package_location=$(ls -t /usr/src | head -n 1)
kernel_ver=$(ls -t /lib/modules | head -n 1)

(
cd /usr/src/${cse_package_location}
sudo rm -rf /lib/modules/${kernel_ver}/extra
sudo dkms install . -k ${kernel_ver}
)

cd $PRODUCT_DIR/bin
mei_modules=$(ls *.ko)
mei_dkms=$(ls /lib/modules/${kernel_ver}/extra)

missing_modules=""
for module in ${mei_modules}; do
    if [[ "${mei_dkms}" != *"$module"* ]]; then
        missing_modules+="${module} "
    fi
done

if [[ ! -z $missing_modules ]]; then
    echo "Error: missing modules: ${missing_modules}"
    exit 1
fi

dkms status
