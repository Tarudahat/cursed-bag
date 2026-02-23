#!/bin/sh
printf '\033c\033]0;%s\a' Cursed Bag
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Cursed Bag.x86_64" "$@"
