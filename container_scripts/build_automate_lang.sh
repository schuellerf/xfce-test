#!/usr/bin/env bash
python3 /data/xfce-test/container_scripts/patch_automate_po.py

./autogen.sh $AUTOGEN_OPTIONS
make clean all
sudo make install

