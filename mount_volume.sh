#! /bin/bash
#
# Mount volumes in apps.
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
s/\$IRODSFS_OVERLAYFS_PVC_NAME/$(escape $IRODSFS_FUSEOVERLAYFS_PVC_NAME)/g

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
    expand_tmpl $baseDir/app/irodsfs_iozone.yaml.template | kubectl apply -f -
    kubectl wait --for=condition=Completed pod/$IOZONE_NAME

    expand_tmpl $baseDir/app/irodsfs_overlayfs_iozone.yaml.template | kubectl apply -f -
    kubectl wait --for=condition=Completed pod/$IOZONE_OVERLAYFS_NAME

    expand_tmpl $baseDir/app/irodsfs_fuseoverlayfs_iozone.yaml.template | kubectl apply -f -
    kubectl wait --for=condition=Completed pod/$IOZONE_FUSEOVERLAYFS_NAME
}


main "$@"

