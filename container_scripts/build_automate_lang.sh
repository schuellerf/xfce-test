#!/usr/bin/env bash
python3 /data/container_scripts/patch_automate_po.py

./autogen.sh --disable-debug --enable-maintainer-mode --host=x86_64-linux-gnu \
             --build=x86_64-linux-gnu --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu \
             --libexecdir=/usr/lib/x86_64-linux-gnu --sysconfdir=/etc --localstatedir=/var --enable-gtk3 --enable-gtk-doc
make clean all
sudo make install

