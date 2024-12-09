#!/bin/bash

# Check if the user provided the path to the QCOW2 image
if [ -z "$2" ]; then
  echo "Usage: $0 /path/to/image.qcow2 mount_point"
  exit 1
fi

QCOW2_IMAGE="$1"
MOUNT_POINT="${2:-/mnt/qcow2}"  # Default mount point is /mnt/qcow2 if not provided

# Load the nbd module
echo "Loading nbd module..."
sudo modprobe nbd max_part=8

# Connect the QCOW2 image to an NBD device
echo "Connecting QCOW2 image to /dev/nbd0..."
sudo qemu-nbd --connect=/dev/nbd0 "$QCOW2_IMAGE"
if [ $? -ne 0 ]; then
  echo "Failed to connect the QCOW2 image."
  exit 1
fi

# Wait for the device to be ready
sleep 2

# List partitions and mount them
echo "Listing partitions in /dev/nbd0..."
PARTITIONS=$(lsblk -lno NAME /dev/nbd0 | grep nbd0p)
if [ -z "$PARTITIONS" ]; then
  echo "No partitions found."
  sudo qemu-nbd --disconnect /dev/nbd0
  exit 1
fi

# Create the main mount point if it doesn't exist
mkdir -p "$MOUNT_POINT"

# Loop through each partition and mount it
for PARTITION in $PARTITIONS; do
  PARTITION_PATH="/dev/$PARTITION"
  PARTITION_MOUNT_POINT="$MOUNT_POINT/$PARTITION"

  echo "Mounting $PARTITION_PATH to $PARTITION_MOUNT_POINT..."
  mkdir -p "$PARTITION_MOUNT_POINT"
  sudo mount "$PARTITION_PATH" "$PARTITION_MOUNT_POINT"
  if [ $? -ne 0 ]; then
    echo "Failed to mount $PARTITION_PATH."
  else
    echo "$PARTITION_PATH mounted to $PARTITION_MOUNT_POINT."
  fi
done

# Trap exit to unmount and disconnect
trap cleanup EXIT

cleanup() {
  echo "Unmounting all partitions..."
  for PARTITION in $PARTITIONS; do
    PARTITION_MOUNT_POINT="$MOUNT_POINT/$PARTITION"
    sudo umount "$PARTITION_MOUNT_POINT"
    echo "Unmounted $PARTITION_MOUNT_POINT."
  done

  echo "Disconnecting the NBD device..."
  sudo qemu-nbd --disconnect /dev/nbd0

  echo "Cleanup done."
}

# Keep the script running to maintain the mounts
echo "Press Ctrl+C to unmount all partitions and disconnect."
while :; do sleep 1; done

