#!/usr/bin/env bash
set -ex

OS_PATH="agama/linux/ubuntu/20.04"

rm -f $OS_PATH/intel-platform-cse-*.deb
cp output/cse/*.deb $OS_PATH/.