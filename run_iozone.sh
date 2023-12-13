#! /bin/bash
#
# Run iozone.
cfg=config.inc

set -e


if [[ "$OSTYPE" == "darwin"* ]]
then
    readonly ExecName=$(greadlink -f "$0")
else
    readonly ExecName=$(readlink --canonicalize "$0")
fi


# escapes / and \ for sed script
escape()
{
    local var="$*"

    # Escape \ first to avoid escaping the escape character, i.e. avoid / -> \/ -> \\/
    var="${var//\\/\\\\}"

    printf '%s' "${var//\//\\/}"
}


expand_tmpl()
{
    cat <<EOF | sed --file - "$1"
s/\$IRODSFS_PVC_NAME/$(escape $IRODSFS_PVC_NAME)/g
s/\$IRODSFS_OVERLAYFS_PVC_NAME/$(escape $IRODSFS_OVERLAYFS_PVC_NAME)/g
s/\$IRODSFS_FUSEOVERLAYFS_PVC_NAME/$(escape $IRODSFS_FUSEOVERLAYFS_PVC_NAME)/g

s/\$IOZONE_NAME/$(escape $IOZONE_NAME)/g
s/\$IOZONE_OVERLAYFS_NAME/$(escape $IOZONE_OVERLAYFS_NAME)/g
s/\$IOZONE_FUSEOVERLAYFS_NAME/$(escape $IOZONE_FUSEOVERLAYFS_NAME)/g
EOF
}

main()
{
    local baseDir=$(dirname "$ExecName")
  
    . "$baseDir/$cfg"

    # iozone
    echo "running iozone with iRODS FUSE Lite"
    expand_tmpl $baseDir/app/irodsfs_iozone.yaml.template | kubectl apply -f -
    echo "wait for the pod to become ready"
    kubectl wait --timeout=60s --for=condition=ready pod/$IOZONE_NAME
    if [$? -eq 0]
    then
        echo "wait for the pod to complete iozone benchmark"
        kubectl wait --timeout=-1s --for=condition=ready=False pod/$IOZONE_NAME
    else
        echo "timeout"
        return -1
    fi

    echo "running iozone with iRODS FUSE Lite + OverlayFS"
    expand_tmpl $baseDir/app/irodsfs_overlayfs_iozone.yaml.template | kubectl apply -f -
    echo "wait for the pod to become ready"
    kubectl wait --timeout=60s --for=condition=ready pod/$IOZONE_OVERLAYFS_NAME
    if [$? -eq 0]
    then
        echo "wait for the pod to complete iozone benchmark"
        kubectl wait --timeout=-1s --for=condition=ready=False pod/$IOZONE_OVERLAYFS_NAME
    else 
        echo "timeout"
        return -1
    fi
    
    echo "running iozone with iRODS FUSE Lite + Fuse-OverlayFS"
    expand_tmpl $baseDir/app/irodsfs_fuseoverlayfs_iozone.yaml.template | kubectl apply -f -
    echo "wait for the pod to become ready"
    kubectl wait --timeout=60s --for=condition=ready pod/$IOZONE_FUSEOVERLAYFS_NAME
    if [$? -eq 0]
    then
        echo "wait for the pod to complete iozone benchmark"
        kubectl wait --timeout=-1s --for=condition=ready=False pod/$IOZONE_FUSEOVERLAYFS_NAME
    else
        echo "timeout"
        return -1
    fi

    return 0
}


main "$@"

