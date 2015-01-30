#!/bin/sh

# @author: Mio <mio@n-n.moe>
# IRC: Mio #nyaa-nyaa@rizon.net
#
# Purpose: Choose a random wallpaper from a folder, apply filters
# and set as background image for the computers bootloader
#
# Target: Should work for UNIX and Linux systems with proper config
#
# Prerequisites:
#  - Imagemagick

################
# Config Begin #
################

# Directory of wallpapers, must be absolute to run at system start up.
PICTURE_DIRECTORY="/Users/pavelkiryanov/Pictures/Retina Anime:Vocaloid Wallpapers"

# Location to store the new photo after operations relative to EFI root.
DESTINATION="/EFI/Boot/rEFInd-minimal/test-background.png"

# Partition to mount
EFI_PARTITION="/dev/disk0s1"

# Where to mount
MNT_LOCATION="/Volumes"

# Mount as what folder
MNT_NAME="/efi"

# Hint:
# For me my image i want to replace is in
# /Volumes/efi/EFI/Boot/rEFInd-minimal/test-background.png
# Assuming I mount EFI at eft

# Resolution of your boot loader
BOOTLOADER_RES_W="2880"
BOOTLOADER_RES_H="1800"

# NB! Please add this script to the sudoers file like this:
# `YOURUSERNAME  ALL=(ALL) NOPASSWD: /path/to/install/auto-efi-wallpaper.sh`
# Where YOURUSERNAME is your username and your path is changed to match
#
# Why? To mount the EFI partition you need sudo, end of story.

# Want to start on boot for Mac?
# @see http://stackoverflow.com/questions/6442364/running-script-upon-login-mac

################
# Config End   #
################

# Sanity check
command -v convert >/dev/null 2>&1 || { echo >&2 "Imagemagick is not installed. Check your package manager and try again. Aborting."; exit 1; }

# Mount
mkdir ${MNT_LOCATION}${MNT_NAME}
sudo mount -t msdos ${EFI_PARTITION} ${MNT_LOCATION}${MNT_NAME}

# Choose image to process.

# Internal Field Separator set to newline, so file names with
# spaces do not break our script.
IFS='
'

# Build images array
images=($(find ${PICTURE_DIRECTORY} -maxdepth 1 -name *.jpg -o -name *.png))

# Generating a random number from 0 to ${#images[@]}
rand="$(expr $RANDOM % ${#images[@]})"

# Get directory of final file
picture=${images[$rand]}

# Preform image processing
convert ${picture} -resize ${BOOTLOADER_RES_W}x${BOOTLOADER_RES_H}^ -gravity center -crop ${BOOTLOADER_RES_W}x${BOOTLOADER_RES_H}+0+0 +repage /tmp/efi_image.png
convert /tmp/efi_image.png -blur 100x25 /tmp/efi_image_blur.png

# Put image in its right place
sudo mv /tmp/efi_image_blur.png ${MNT_LOCATION}${MNT_NAME}${DESTINATION}

# Unmount
sudo umount -f ${MNT_LOCATION}${MNT_NAME}
