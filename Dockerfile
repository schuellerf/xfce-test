FROM fedora:29
MAINTAINER Florian Schüller <florian.schueller@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV DISPLAY ${DISPLAY:-:1}

# Test specific
# python-wheel is a missing dependency from behave
# psmisc for "killall"
# ffmpeg is only in "rpmfusion-free"
RUN dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
 && dnf -y update \
 && dnf -y install psmisc xorg-x11-utils procps ffmpeg \
 && dnf -y install dirmngr git ldtp python-pip python-wheel python-dogtail python-psutil vim sudo gdb valgrind cmake \
 && dnf clean all

RUN /usr/bin/pip install behave ldtp

# Xfce specific build dependencies
RUN dnf -y update \
 && dnf -y install xfce4-appfinder tumbler xfce4-terminal xfce4-clipman-plugin xfce4-screenshooter xfce4-power-manager xfce4-notifyd librsvg2 \
 && dnf -y builddep xfce4-panel Thunar xfce4-settings xfce4-session xfdesktop xfwm4 xfce4-appfinder tumbler xfce4-terminal xfce4-clipman-plugin xfce4-screenshooter \
 && dnf clean all

#needed for LDTP and friends
RUN /usr/bin/dbus-run-session /usr/bin/gsettings set org.gnome.desktop.interface toolkit-accessibility true

# Create the directory for version_info.txt
RUN useradd -ms /bin/bash test_user

RUN usermod test_user -G wheel
RUN sed -i "s/^%wheel.*/%wheel ALL=(ALL) NOPASSWD:ALL/" /etc/sudoers

# Group all repos here
RUN mkdir /git

# Rather use my patched version
RUN cd git \
 && git clone https://github.com/schuellerf/ldtp2.git \
 && cd ldtp2 \
 && python setup.py install

# Install _all_ languages for testing
RUN dnf -y update \
 && dnf -y install transifex-client xautomation $(dnf search glibc-langpack-|grep -oP "^glibc-langpack-...?(?=.x86)") \
 && dnf clean all

# Line used to invalidate all git clones
ARG DOWNLOAD_DATE=give_me_a_date
ENV DOWNLOAD_DATE=$DOWNLOAD_DATE
RUN echo "Newly cloning all repos as date-flag changed to ${DOWNLOAD_DATE}"
ARG AUTOGEN_OPTIONS="--disable-debug --enable-maintainer-mode --host=x86_64-linux-gnu \
                    --build=x86_64-linux-gnu --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu \
                    --libexecdir=/usr/lib/x86_64-linux-gnu --sysconfdir=/etc --localstatedir=/var --enable-gtk3 --enable-gtk-doc"

## Grab xfce4-dev-tools from master
#RUN cd git \
#  && git clone git://git.xfce.org/xfce/xfce4-dev-tools \
#  && cd xfce4-dev-tools \
#  && ./autogen.sh $AUTOGEN_OPTIONS \
#  && make \
#  && make install \
#  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt \
#  && ldconfig

## Grab libxfce4util from master
#RUN cd git \
#  && git clone git://git.xfce.org/xfce/libxfce4util \
#  && cd libxfce4util \
#  && ./autogen.sh $AUTOGEN_OPTIONS \
#  && make \
#  && make install \
#  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt \
#  && ldconfig

## Grab xfconf from master
#RUN cd git \
#  && git clone git://git.xfce.org/xfce/xfconf \
#  && cd xfconf \
#  && ./autogen.sh $AUTOGEN_OPTIONS \
#  && make \
#  && make install \
#  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt \
#  && ldconfig

## Grab libxfce4ui from master
#RUN cd git \
#  && git clone git://git.xfce.org/xfce/libxfce4ui \
#  && cd libxfce4ui \
#  && ./autogen.sh $AUTOGEN_OPTIONS \
#  && make \
#  && make install \
#  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt \
#  && ldconfig

## Grab garcon from master
#RUN cd git \
#  && git clone git://git.xfce.org/xfce/garcon \
#  && cd garcon \
#  && ./autogen.sh $AUTOGEN_OPTIONS \
#  && make \
#  && make install \
#  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt \
#  && ldconfig

## Grab exo from master
#RUN cd git \
#  && git clone git://git.xfce.org/xfce/exo \
#  && cd exo \
#  && ./autogen.sh $AUTOGEN_OPTIONS \
#  && make \
#  && make install \
#  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt \
#  && ldconfig

# Grab xfce4-panel
RUN cd git \
  && git clone git://git.xfce.org/xfce/xfce4-panel \
  && cd xfce4-panel \
  && ./autogen.sh $AUTOGEN_OPTIONS \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab thunar
RUN cd git \
  && git clone git://git.xfce.org/xfce/thunar \
  && cd thunar \
  && ./autogen.sh $AUTOGEN_OPTIONS \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab xfce4-settings
RUN cd git \
  && git clone git://git.xfce.org/xfce/xfce4-settings \
  && cd xfce4-settings \
  && ./autogen.sh $AUTOGEN_OPTIONS \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt


# Grab xfce4-session
RUN cd git \
  && git clone git://git.xfce.org/xfce/xfce4-session \
  && cd xfce4-session \
  && ./autogen.sh $AUTOGEN_OPTIONS \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab xfdesktop
RUN cd git \
  && git clone git://git.xfce.org/xfce/xfdesktop \
  && cd xfdesktop \
  && ./autogen.sh $AUTOGEN_OPTIONS \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab xfwm4
RUN cd git \
  && git clone git://git.xfce.org/xfce/xfwm4 \
  && cd xfwm4 \
  && ./autogen.sh $AUTOGEN_OPTIONS \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab xfce4-appfinder
RUN cd git \
  && git clone git://git.xfce.org/xfce/xfce4-appfinder \
  && cd xfce4-appfinder \
  && ./autogen.sh $AUTOGEN_OPTIONS \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab tumbler
RUN cd git \
  && git clone git://git.xfce.org/xfce/tumbler \
  && cd tumbler \
  && ./autogen.sh $AUTOGEN_OPTIONS \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab xfce4-terminal
RUN cd git \
  && git clone git://git.xfce.org/apps/xfce4-terminal \
  && cd xfce4-terminal \
  && ./autogen.sh $AUTOGEN_OPTIONS \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab xfce4-whiskermenu-plugin
RUN cd git \
  && git clone git://git.xfce.org/panel-plugins/xfce4-whiskermenu-plugin \
  && cd xfce4-whiskermenu-plugin \
  && mkdir build && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr .. \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab xfce4-clipman
RUN cd git \
  && git clone git://git.xfce.org/panel-plugins/xfce4-clipman-plugin \
  && cd xfce4-clipman-plugin \
  && ./autogen.sh $AUTOGEN_OPTIONS \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab xfce4-screenshooter
RUN cd git \
  && git clone git://git.xfce.org/apps/xfce4-screenshooter \
  && cd xfce4-screenshooter \
  && ./autogen.sh $AUTOGEN_OPTIONS \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

RUN pip install opencv-python

# TBD language generation - it's different than in ubuntu...
#RUN cp -r /usr/share/locale/en_GB /usr/share/locale/automate
#RUN sed -i -E "s/Language: en/Language: automate/" /usr/share/locale/automate
#RUN sed -i -E "s/lang_lib +\"eng\"/lang_lib    \"automate\"/" /usr/share/i18n/locale/automate
#RUN sed -i -E "s/lang_name +\"English\"/lang_name     \"Automate\"/" /usr/share/i18n/locale/automate
#RUN bash -c "cd /usr/share/i18n/locale;localedef -i automate -f UTF-8 automate.UTF-8 -c -v || echo Ignoring warnings..."
#RUN echo "automate UTF-8" > /var/lib/locale/supported.d/automate
#RUN locale-gen automate
#RUN dpkg-reconfigure fontconfig

COPY behave /behave_tests

RUN chown -R test_user /git /behave_tests

COPY xfce-test /
COPY container_scripts /container_scripts
RUN chmod a+x /xfce-test /container_scripts/*.sh /container_scripts/*.py

USER test_user
ENV HOME /home/test_user
ENV AUTOGEN_OPTIONS $AUTOGEN_OPTIONS

RUN mkdir -p ~test_user/Desktop
RUN ln -s /container_scripts ~test_user/Desktop/container_scripts

RUN echo 'if [[ $- =~ "i" ]]; then echo -n "This container includes:\n"; cat ~test_user/version_info.txt; fi' >> ~test_user/.bashrc

CMD [ "/container_scripts/entrypoint.sh" ]
