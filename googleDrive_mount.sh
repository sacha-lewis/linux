#!/bin/bash

# This requires to setup a google api
# ttps://rclone.org/drive/#making-your-own-client-id

sudo apt install rclone

rclone config

# n) New remote
# drive
# Google Drive

# mkdir ~/GoogleDrive

# rclone mount drive: ~/GoogleDrive --vfs-cache-mode writes