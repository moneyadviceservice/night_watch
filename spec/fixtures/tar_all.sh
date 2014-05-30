#! /usr/bin/env bash

for dir in `ls -d */ | xargs basename`; do
  tarball="$dir.tar.gz"
  printf "Creating $tarball from $dir... "
  tar -czf $tarball -C $dir .
  rm -rf $dir
  echo "done"
done
