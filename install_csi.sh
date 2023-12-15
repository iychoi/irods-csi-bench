#! /bin/bash
#
# Install irods-csi-driver.
cfg=config.inc

set -e


if [[ "$OSTYPE" == "darwin"* ]]
then
    readonly ExecName=$(greadlink -f "$0")
else
    readonly ExecName=$(readlink --canonicalize "$0")
fi

main()
{
    local baseDir=$(dirname "$ExecName")
  
    . "$baseDir/$cfg"

    # install helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # irods-csi-driver
    helm repo add irods-csi-driver-repo https://cyverse.github.io/irods-csi-driver-helm/
    helm repo update
    helm install irods-csi-driver irods-csi-driver-repo/irods-csi-driver
}


main "$@"

