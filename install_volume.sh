#! /bin/bash
#
# Install volumes using iRODS-CSI-Driver.
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
s/\$IRODS_HOST/$(escape $IRODS_HOST)/g
s/\$IRODS_PORT/$(escape $IRODS_PORT)/g
s/\$IRODS_ZONE/$(escape $IRODS_ZONE)/g
s/\$IRODS_USER/$(escape $IRODS_USER)/g
s/\$IRODS_PASSWORD/$(escape $IRODS_PASSWORD)/g

s/\$IRODSFS_PV_NAME/$(escape $IRODSFS_PV_NAME)/g
s/\$IRODSFS_PVC_NAME/$(escape $IRODSFS_PVC_NAME)/g
s/\$IRODSFS_PV_ID/$(escape $IRODSFS_PV_ID)/g

s/\$IRODSFS_OVERLAYFS_PV_NAME/$(escape $IRODSFS_OVERLAYFS_PV_NAME)/g
s/\$IRODSFS_OVERLAYFS_PVC_NAME/$(escape $IRODSFS_OVERLAYFS_PVC_NAME)/g
s/\$IRODSFS_OVERLAYFS_PV_ID/$(escape $IRODSFS_OVERLAYFS_PV_ID)/g

s/\$IRODSFS_OVERLAYFS_PV_NAME/$(escape $IRODSFS_FUSEOVERLAYFS_PV_NAME)/g
s/\$IRODSFS_OVERLAYFS_PVC_NAME/$(escape $IRODSFS_FUSEOVERLAYFS_PVC_NAME)/g
s/\$IRODSFS_OVERLAYFS_PV_ID/$(escape $IRODSFS_FUSEOVERLAYFS_PV_ID)/g
EOF
}

main()
{
    local baseDir=$(dirname "$ExecName")
  
    . "$baseDir/$cfg"

    # irods-csi-driver sc
    cat $baseDir/csi_volume/sc.yaml | kubectl apply -f -

    # irodsfs pv and pvc
    expand_tmpl $baseDir/csi_volume/irodsfs_pv.yaml.template | kubectl apply -f -
    expand_tmpl $baseDir/csi_volume/irodsfs_pvc.yaml.template | kubectl apply -f -

    # irodsfs overlayfs pv and pvc
    expand_tmpl $baseDir/csi_volume/irodsfs_overlayfs_pv.yaml.template | kubectl apply -f -
    expand_tmpl $baseDir/csi_volume/irodsfs_overlayfs_pvc.yaml.template | kubectl apply -f -

    # irodsfs fuse-overlayfs pv and pvc
    expand_tmpl $baseDir/csi_volume/irodsfs_fuseoverlayfs_pv.yaml.template | kubectl apply -f -
    expand_tmpl $baseDir/csi_volume/irodsfs_fuseoverlayfs_pvc.yaml.template | kubectl apply -f -
}


main "$@"

