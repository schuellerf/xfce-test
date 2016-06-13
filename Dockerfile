FROM ubuntu:16.04
MAINTAINER Florian Schüller <florian.schueller@gmail.com>

RUN \
  apt-get update && \
  apt-get -y install \
          xfce4-terminal xfce4-panel xfce4-session && \
  apt-get -y install \
          libxfce4panel-2.0-dev libxfce4util-dev libxfconf-0-dev xfce4-dev-tools git build-essential libgtk-3-dev gtk-doc-tools libgtk2.0-dev libx11-dev libglib2.0-dev && \
  apt-get -y install \
          python-dogtail && \
rm -rf /var/lib/apt/lists/*


# Replace 1000 with your user / group id
#RUN export uid=1000 gid=1000 && \
#    mkdir -p /home/developer && \
#    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
#    echo "developer:x:${uid}:" >> /etc/group && \
#    chown ${uid}:${gid} -R /home/developer

#libxfce4ui tag
RUN git clone git://git.xfce.org/xfce/libxfce4ui \
 && cd /libxfce4ui \
 && git checkout libxfce4ui-4.13.0 \
 && ./autogen.sh \
 && make \
 && make install \
 && ldconfig

#clipman plugin
RUN git clone git://git.xfce.org/panel-plugins/xfce4-clipman-plugin \
 && cd /xfce4-clipman-plugin \
 && ./autogen.sh \
 && make \
 && make install


#USER developer
#ENV HOME /home/developer

CMD xfce4-session
