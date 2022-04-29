#!/usr/bin/env bash
set -ex

OS_PATH="agama/linux/rhel/8.5"

rm $OS_PATH/intel-platform-cse-*.rpm
cp output/cse/*.rpm $OS_PATH/.