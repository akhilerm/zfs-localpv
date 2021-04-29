#!/bin/bash

# Copyright 2019 The Kubernetes Authors.
# Copyright 2020 The OpenEBS Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

## find or download controller-gen
CONTROLLER_GEN=$(which controller-gen)

if [ "$CONTROLLER_GEN" = "" ]
then
  echo "ERROR: failed to get controller-gen, Please run make bootstrap to install it";
  exit 1;
fi

$CONTROLLER_GEN crd:trivialVersions=false,preserveUnknownFields=false paths=./pkg/apis/... output:crd:artifacts:config=deploy/yamls

## create the the crd yamls

echo '

##############################################
###########                       ############
###########   ZFSVolume CRD       ############
###########                       ############
##############################################

# ZFSVolume CRD is autogenerated via `make manifests` command.
# Do the modification in the code and run the `make manifests` command
# to generate the CRD definition' > deploy/yamls/zfsvolume-crd.yaml

cat deploy/yamls/zfs.openebs.io_zfsvolumes.yaml >> deploy/yamls/zfsvolume-crd.yaml
rm deploy/yamls/zfs.openebs.io_zfsvolumes.yaml

echo '

##############################################
###########                       ############
###########   ZFSSnapshot CRD     ############
###########                       ############
##############################################

# ZFSSnapshot CRD is autogenerated via `make manifests` command.
# Do the modification in the code and run the `make manifests` command
# to generate the CRD definition' > deploy/yamls/zfssnapshot-crd.yaml

cat deploy/yamls/zfs.openebs.io_zfssnapshots.yaml >> deploy/yamls/zfssnapshot-crd.yaml
rm deploy/yamls/zfs.openebs.io_zfssnapshots.yaml

echo '

##############################################
###########                       ############
###########   ZFSBackup CRD       ############
###########                       ############
##############################################

# ZFSBackups CRD is autogenerated via `make manifests` command.
# Do the modification in the code and run the `make manifests` command
# to generate the CRD definition' > deploy/yamls/zfsbackup-crd.yaml

cat deploy/yamls/zfs.openebs.io_zfsbackups.yaml >> deploy/yamls/zfsbackup-crd.yaml
rm deploy/yamls/zfs.openebs.io_zfsbackups.yaml

echo '

##############################################
###########                       ############
###########   ZFSRestore CRD      ############
###########                       ############
##############################################

# ZFSRestores CRD is autogenerated via `make manifests` command.
# Do the modification in the code and run the `make manifests` command
# to generate the CRD definition' > deploy/yamls/zfsrestore-crd.yaml

cat deploy/yamls/zfs.openebs.io_zfsrestores.yaml >> deploy/yamls/zfsrestore-crd.yaml
rm deploy/yamls/zfs.openebs.io_zfsrestores.yaml

## create the operator file using all the yamls

echo '# This manifest is autogenerated via `make manifests` command
# Do the modification to the zfs-driver.yaml in directory deploy/yamls/
# and then run `make manifests` command

# This manifest deploys the OpenEBS ZFS control plane components,
# with associated CRs & RBAC rules.
' > deploy/zfs-operator.yaml

# Add namespace creation to the Operator yaml
cat deploy/yamls/namespace.yaml >> deploy/zfs-operator.yaml

# Add ZFSVolume v1alpha1 and v1 CRDs to the Operator yaml
cat deploy/yamls/zfsvolume-crd.yaml >> deploy/zfs-operator.yaml

# Add ZFSSnapshot v1alpha1 and v1 CRDs to the Operator yaml
cat deploy/yamls/zfssnapshot-crd.yaml >> deploy/zfs-operator.yaml

# Add ZFSBackup v1 CRDs to the Operator yaml
cat deploy/yamls/zfsbackup-crd.yaml >> deploy/zfs-operator.yaml

# Add ZFSRestore v1 CRDs to the Operator yaml
cat deploy/yamls/zfsrestore-crd.yaml >> deploy/zfs-operator.yaml

# Add the driver deployment to the Operator yaml
cat deploy/yamls/zfs-driver.yaml >> deploy/zfs-operator.yaml

# To use your own boilerplate text use:
#   --go-header-file ${SCRIPT_ROOT}/hack/custom-boilerplate.go.txt
