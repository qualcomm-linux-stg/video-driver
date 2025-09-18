#!/bin/bash
set -e

# Source build output path
ls
cd ..
ls
BUILD_PATH="build/tmp/deploy/images"

# Target images directory
TARGET_DIR="images"

# Create target directory
mkdir -p $TARGET_DIR

# Copy image folders
cp -r $BUILD_PATH/qcs8300-ride-sx $TARGET_DIR/
cp -r $BUILD_PATH/qcs9100-ride-sx $TARGET_DIR/
cp -r $BUILD_PATH/qcom-multimedia-proprietary-image-qcs8300-ride-sx.rootfs.qcomflash $TARGET_DIR/

# App injection function
inject_app() {
  IMG_DIR="$1"
  ROOTFS="$IMG_DIR/rootfs.img"
  MOUNT_DIR="system_mount"

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

# Inject into all three images
inject_app "$TARGET_DIR/qcs8300-ride-sx/qcom-multimedia-proprietary-image-qcs8300-ride-sx.rootfs.qcomflash"
inject_app "$TARGET_DIR/qcs9100-ride-sx/qcom-multimedia-proprietary-image-qcs8300-ride-sx.rootfs.qcomflash"
inject_app "$TARGET_DIR/qcom-multimedia-proprietary-image-qcs8300-ride-sx.rootfs.qcomflash/qcom-multimedia-proprietary-image-qcs8300-ride-sx.rootfs.qcomflash"
