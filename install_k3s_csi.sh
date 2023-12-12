#! /bin/bash
#
# Install k3s.
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

    # k3s
    echo "Installing k3s"
    curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=$K3S_VERSION sh -

    # kubectl
    echo "Installing kubectl"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install kubectl /usr/local/bin/kubectl
    rm kubectl

    # configure kubectl
    echo "Configuring kubectl config"
    mkdir -p ~/.kube
    sudo k3s kubectl config view --raw | tee ~/.kube/config
    chmod 600 ~/.kube/config

    # install helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # irods-csi-driver
    helm repo add irods-csi-driver-repo https://cyverse.github.io/irods-csi-driver-helm/
    helm repo update
    helm install irods-csi-driver irods-csi-driver-repo/irods-csi-driver
}


main "$@"

