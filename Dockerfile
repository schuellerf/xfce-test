FROM ubuntu:17.04
MAINTAINER Florian Schüller <florian.schueller@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV DISPLAY ${DISPLAY:-:1}

# Test specific
# python-wheel is a missing dependency from behave
RUN apt-get update \
 && apt-get -y --no-install-recommends install apt-utils \
 && apt-get -y install dirmngr git python-ldtp ldtp python-pip python-wheel

RUN /usr/bin/pip install --upgrade pip
RUN /usr/bin/pip install behave

COPY xubuntu-dev-xfce4-gtk3-zesty.list /etc/apt/sources.list.d/
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB563F93142986CE

#XFCE specific
RUN apt-get update \
 && apt-get -y install xfce4-terminal xfce4-panel xfce4-session gnome-themes-standard \
 && apt-get -y build-dep xfce4-panel \
 && apt-get -y build-dep garcon \
 && apt-get -y install libglib2.0-bin libxfce4panel-2.0-dev libxfce4util-dev libxfconf-0-dev xfce4-dev-tools build-essential libgtk-3-dev gtk-doc-tools libgtk2.0-dev libx11-dev libglib2.0-dev libwnck-3-dev \
 && rm -rf /var/lib/apt/lists/*

#needed for LDTP and friends
RUN /usr/bin/dbus-run-session /usr/bin/gsettings set org.gnome.desktop.interface toolkit-accessibility true

# create the directory for version_info.txt
RUN useradd -ms /bin/bash test_user

# group all repos here
RUN mkdir /git

# rather use my patched version
RUN cd git \
 && git clone https://github.com/schuellerf/ldtp2.git \
 && cd ldtp2 \
 && python setup.py install

# line used to invalidate all git clones
ARG DOWNLOAD_DATE=give_me_a_date

# Grab garcon from master
RUN cd git \
  && git clone git://git.xfce.org/xfce/garcon \
  && cd garcon \
  && ./autogen.sh --enable-debug --enable-maintenance-mode \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt \
  && ldconfig

# Grab exo from exo-0.11.2
RUN cd git \
  && git clone -b exo-0.11.2 git://git.xfce.org/xfce/exo \
  && cd exo \
  && ./autogen.sh \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt \
  && ldconfig

# Grab xfce4-panel
RUN cd git \
  && git clone git://git.xfce.org/xfce/xfce4-panel \
  && cd xfce4-panel \
  && ./autogen.sh --enable-debug --enable-maintainer-mode --host=x86_64-linux-gnu \
        --build=x86_64-linux-gnu --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu \
        --libexecdir=/usr/lib/x86_64-linux-gnu --enable-gtk3 --enable-gtk-doc \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab xfce4-clipman
RUN cd git \
  && git clone git://git.xfce.org/panel-plugins/xfce4-clipman-plugin \
  && cd xfce4-clipman-plugin \
  && ./autogen.sh \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab xfce4-appfinder
RUN cd git \
  && git clone git://git.xfce.org/xfce/xfce4-appfinder \
  && cd xfce4-appfinder \
  && ./autogen.sh --prefix=/usr \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

# Grab xfwm4
RUN cd git \
  && git clone -b xfwm4-4.12.4 git://git.xfce.org/xfce/xfwm4 \
  && cd xfwm4 \
  && ./autogen.sh --prefix=/usr \
  && make \
  && make install \
  && echo "$(pwd): $(git describe)" >> ~test_user/version_info.txt

USER test_user
ENV HOME /home/test_user

RUN echo 'if [[ $- =~ "i" ]]; then echo -n "This container includes:\n"; cat ~test_user/version_info.txt; fi' >> ~test_user/.bashrc

COPY behave /behave_tests

CMD [ "/bin/bash", "-c", "xfce4-session" ]
