FROM ubuntu:17.04
MAINTAINER Florian Schüller <florian.schueller@gmail.com>

ENV AVOCADO_BRANCH ${AVOCADO_BRANCH:-master}

#Test specific
RUN \
  apt-get update && \
  apt-get -y install \
          git python-psutil python-ldtp python-dogtail ldtp libglib2.0-bin python-libvirt python-setuptools python-pip libvirt0 libvirt-dev liblzma-dev libyaml-dev && \
  rm -rf /var/lib/apt/lists/*

RUN git clone --branch ${AVOCADO_BRANCH} https://github.com/avocado-framework/avocado.git && \
    cd avocado && pip install -r requirements.txt && python setup.py install && make link && \
    echo "pip freeze" >> /etc/avocado/sysinfo/commands

#needed for LDTP and friends
RUN /usr/bin/gsettings set org.gnome.desktop.interface toolkit-accessibility true

COPY xubuntu-dev-xfce4-gtk3-zesty.list /etc/apt/sources.list.d/
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB563F93142986CE

#XFCE specific
RUN \
  apt-get update && \
  apt-get -y install \
          xfce4-terminal xfce4-panel xfce4-session gnome-themes-standard && \
  apt-get -y build-dep xfce4-panel && \
  apt-get -y build-dep garcon && \
  apt-get -y install \
          libxfce4panel-2.0-dev libxfce4util-dev libxfconf-0-dev xfce4-dev-tools build-essential libgtk-3-dev gtk-doc-tools libgtk2.0-dev libx11-dev libglib2.0-dev libwnck-3-dev && \
  rm -rf /var/lib/apt/lists/*


# Replace 1000 with your user / group id
#RUN export uid=1000 gid=1000 && \
#    mkdir -p /home/developer && \
#    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
#    echo "developer:x:${uid}:" >> /etc/group && \
#    chown ${uid}:${gid} -R /home/developer

# Grab garcon from master
RUN git clone git://git.xfce.org/xfce/garcon \
  && cd garcon \
  && ./autogen.sh \
  && make \
  && make install \
  && ldconfig

# Grab xfce4-panel from master
RUN git clone git://git.xfce.org/xfce/xfce4-panel \
  && cd xfce4-panel \
  && ./autogen.sh --prefix=/usr \
  && make \
  && make install

# Grab xfce4-clipman from master
RUN git clone git://git.xfce.org/panel-plugins/xfce4-clipman-plugin \
  && cd /xfce4-clipman-plugin \
  && ./autogen.sh \
  && make \
  && make install

# Grab xfce4-appfinder from master
RUN git clone git://git.xfce.org/xfce/xfce4-appfinder \
  && cd xfce4-appfinder \
  && ./autogen.sh --prefix=/usr \
  && make \
  && make install

#USER developer
#ENV HOME /home/developer

CMD [ "/bin/bash", "-c", "xfce4-session" ]
