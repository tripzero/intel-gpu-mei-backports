set -ex

(
cd output/cse
sudo dpkg -i intel-platform-cse-*.deb
)

kernel_ver=$(ls -t /lib/modules | head -n 1)
sudo rm -rf /lib/modules/${kernel_ver}/updates/dkms
sudo dkms autoinstall . -k ${kernel_ver}

cd $PRODUCT_DIR/bin
mei_modules=$(ls *.ko)

mei_dkms=$(ls /lib/modules/${kernel_ver}/updates/dkms)
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