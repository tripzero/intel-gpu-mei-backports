set -ex

(
cd output/cse
sudo rpm -i intel-platform-cse-*.rpm --noscripts
)

ls -t /usr/src
cse_package_location=$(ls -t /usr/src | head -n 1)
kernel_ver=$(ls /lib/modules | grep default)

(
cd /usr/src/${cse_package_location}
sudo rm -rf /lib/modules/${kernel_ver}/updates
sudo dkms install . -k ${kernel_ver}
)

cd $PRODUCT_DIR/bin
mei_modules=$(ls *.ko)

mei_dkms=$(ls /lib/modules/${kernel_ver}/updates)
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
