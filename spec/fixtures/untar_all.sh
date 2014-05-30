#! /usr/bin/env bash

for tarball in `ls *.tar.gz`; do
  target_dir=${tarball%%.*}
  printf "Extracting $tarball into $target_dir... "
  rm -rf $target_dir
  mkdir $target_dir
  tar -xzf $tarball -C $target_dir
  rm $tarball
  echo "done"
done
