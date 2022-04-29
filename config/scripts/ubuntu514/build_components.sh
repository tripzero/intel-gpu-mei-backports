#!/usr/bin/env bash
set -ex

# Zero ccache stats
ccache -z

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/copy_firmware.sh
$DIR/build_module.sh
$DIR/oem_kernel_version.sh
$DIR/oem_kernel_instructions.sh
$DIR/build_cse.sh
$DIR/patch_agama.sh
$DIR/install_cse.sh

# Print ccache stats
ccache -s
