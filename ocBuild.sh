#!/usr/bin/env bash
while [ ! -d .git ] && [[ "$HOME" != "$(pwd)" ]]; do
  cd ..;
done
pwd