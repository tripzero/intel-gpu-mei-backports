#!/usr/bin/env bash
set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OS_VERSION="sles/15sp3"

#Copy fw package
mkdir -p output
rm -f firmware/linux/${OS_VERSION}/intel-fw-gpu-internal*

cp -pR firmware/linux/${OS_VERSION}/intel-fw-gpu*.rpm output/.

#Test install
sudo rpm -U --force output/intel-fw-gpu*.rpm