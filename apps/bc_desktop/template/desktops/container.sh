CONTAINER_CMD=${CONTAINER_CMD:-singularity}
CONTAINER_MNTS=${CONTAINER_MNTS:-""}
CONTAINER_ARGS=${CONTAINER_ARGS:-""}
SEPERATOR=${SEPERATOR:-"%"}
  
function singularity_mounts(){
  MOUNTS=$(echo $1 | tr $2 ,)
  echo "-B $MOUNTS"
}

function podman_mounts(){
  IFS="$2" PATHS=($1)

  MOUNTS=""
  for PATH in "${PATHS[@]}"
  do
    MOUNTS="$MOUNTS -v $PATH"
  done

  echo $MOUNTS
}

if [[ "$CONTAINER_CMD" == "singularity" ]]; then
  MOUNT_ARG=$(singularity_mounts $CONTAINER_MNTS $SEPERATOR)
elif [[ "$CONTAINER_CMD" == "podman" ]] || [[ "$CONTAINER_CMD" == "docker" ]]; then
  MOUNT_ARG=$(podman_mounts $CONTAINER_MNTS $SEPERATOR)
fi

CMD="$CONTAINER_CMD run $CONTAINER_ARGS $MOUNT_ARG $CONTAINER_IMAGE $DESKTOP_CMD"

echo "executing $CMD"
$CMD
