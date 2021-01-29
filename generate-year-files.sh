#!/bin/bash
  
set -e

export XPATHX="./year-folder"

mkdir -pv "$XPATHX"

for i in {01..12}
  do
    for j in {01..31}
      do
        if ! touch -mad "2020-$i-$j" "$XPATHX/file-2020-$i-$j"
          then
            echo "Wrong! 2020-$i-$j"
        fi
    done
done

exit 0
