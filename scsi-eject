#!/bin/sh

if test -h "$1"
then
    disk=$(chase "$1")
else
    disk="$1"
fi

if test -b "$disk"
then
    echo 1 >/sys/block/$(basename "$disk")/device/delete
else
    echo "$0: not a block device: $1" >&2
    exit 1
fi
