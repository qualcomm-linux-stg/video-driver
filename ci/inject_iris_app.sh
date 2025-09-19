#!/bin/bash
: <<'END'
set -e

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --image-dir)
      IMAGE_DIR="$2"
      shift 2
      ;;
    --machine)
      MACHINE="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$IMAGE_DIR" || -z "$MACHINE" ]]; then
  echo "Usage: $0 --image-dir <path> --machine <name>"
  exit 1
fi

TARGET_DIR="images"
mkdir -p "$TARGET_DIR"

# Copy relevant image folder
echo "Copying images for $MACHINE..."
cp -r "$IMAGE_DIR/$MACHINE" "$TARGET_DIR/" || echo "⚠️ Folder $IMAGE_DIR/$MACHINE not found"
cp -r "$IMAGE_DIR/qcom-multimedia-proprietary-image-$MACHINE.rootfs.qcomflash" "$TARGET_DIR/" || echo "⚠️ Rootfs image not found"

# App injection function
inject_app() {
  IMG_DIR="$1"
  ROOTFS="$IMG_DIR/rootfs.img"
  MOUNT_DIR="system_mount"

  if [[ ! -f "$ROOTFS" ]]; then
    echo "❌ rootfs.img not found at $ROOTFS"
    return 1
  fi

  echo "Injecting into $ROOTFS"
  mkdir -p $MOUNT_DIR
  sudo mount -o loop "$ROOTFS" $MOUNT_DIR

  sudo mkdir -p $MOUNT_DIR/data/vendor/iris_test_app/input
  sudo mkdir -p $MOUNT_DIR/data/vendor/iris_test_app/output
  sudo cp /local/mnt/workspace/manigurr/iris_v4l2_test $MOUNT_DIR/data/vendor/iris_test_app/
  sudo chmod +x $MOUNT_DIR/data/vendor/iris_test_app/iris_v4l2_test

  sudo umount $MOUNT_DIR
  rm -rf $MOUNT_DIR
}

# Inject into copied images
inject_app "$TARGET_DIR/$MACHINE"
inject_app "$TARGET_DIR"

END



===

inject_app() {
  IMG_DIR="$1"
  MOUNT_DIR="system_mount"

  # Dynamically find the rootfs image
  ROOTFS=$(find "$IMG_DIR" -name "*.rootfs.qcomflash" -o -name "rootfs.img" | head -n 1)

  if [[ -z "$ROOTFS" || ! -f "$ROOTFS" ]]; then
    echo "❌ rootfs image not found in $IMG_DIR"
    return 1
  fi

  echo "Injecting into $ROOTFS"
  mkdir -p $MOUNT_DIR
  sudo mount -o loop "$ROOTFS" $MOUNT_DIR

  sudo mkdir -p $MOUNT_DIR/data/vendor/iris_test_app/input
  sudo mkdir -p $MOUNT_DIR/data/vendor/iris_test_app/output
  sudo cp /local/mnt/workspace/manigurr/iris_v4l2_test $MOUNT_DIR/data/vendor/iris_test_app/
  sudo chmod +x $MOUNT_DIR/data/vendor/iris_test_app/iris_v4l2_test

  sudo umount $MOUNT_DIR
  rm -rf $MOUNT_DIR
}
