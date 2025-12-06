#!/usr/bin/env bash

set -euxo pipefail

source ~/arch_installation/variables.sh
source ~/arch_installation/functions.sh
source ~/arch_installation/config_sync.sh

config_sync ~/arch_installation
