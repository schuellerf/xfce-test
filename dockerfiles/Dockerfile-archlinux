FROM archlinux:latest
LABEL maintainer="noblechuk5[at]web[dot]de"

# only works for ArchLinux
ENV TAG=archlinux

ARG DISPLAY
ENV DISPLAY=${DISPLAY:-':1'}

ARG TRAVIS=false

# default shell for user: bash or zsh
ARG USERSHELL='zsh'

ARG DEFAULT_USER='xfce-test_user'

# pacman helper: paru or yay
ARG PACMAN='yay'

ARG PARALLEL_BUILDS='2'

# Line used to invalidate all git clones
ARG DOWNLOAD_DATE
ENV DOWNLOAD_DATE="${DOWNLOAD_DATE:-epoch}"

ARG MAIN_BRANCH='master'
ENV MAIN_BRANCH="${MAIN_BRANCH}"

# useful for affecting compilation
ARG CFLAGS='-O2 -pipe'

# extract manpage archives from installed packages
ARG EXTRACT_MAN=true

# don't pass in --hosts; let pkgconf use the one it was compiled with
# https://www.freedesktop.org/wiki/Software/pkg-config/CrossCompileProposal/
ARG AUTOGEN_OPTIONS
ENV AUTOGEN_OPTIONS="${AUTOGEN_OPTIONS:-\
    --prefix=/usr/ \
    --sbindir=/usr/bin \
    --libexecdir=/usr/lib/xfce4 \
    --localstatedir=/var \
    --sysconfdir=/etc \
    --disable-debug \
    --disable-dependency-tracking \
    --disable-upower-glib \
    --disable-static \
    --enable-maintainer-mode --enable-systemd --enable-gtk-doc \
    --enable-xrandr --enable-xcursor --enable-libnotify \
    --enable-epoxy --enable-startup-notification --enable-xsync \
    --enable-render --enable-randr --enable-xpresent \
    --enable-compositor --enable-libxklavier --enable-pluggable-dialogs \
    --enable-sound-settings --enable-polkit --disable-network-manager \
    --enable-notifications --enable-gio-unix --enable-gudev \
    --enable-exif --enable-pcre --enable-vala \
    --enable-introspection --enable-sound-settings --enable-gio-unix \
    --with-vala-api=0.36 \
    --with-perl-options=INSTALLDIRS=vendor}"

# allow extraction of man pages?
RUN if (( ${EXTRACT_MAN/#true/1} )); then \
        temp_conf="$(cat /etc/pacman.conf)"; \
        /bin/bash -c 'while IFS= read -r line; do \
            if [[ ! $line =~ ^NoExtract.*usr/share/man.*$ ]]; then \
                echo "$line"; \
            fi; \
        done;' <<< $temp_conf >/etc/pacman.conf; \
    fi

RUN pacman -Syu --noconfirm \
    && pacman -S base-devel git ${USERSHELL} man-db --noconfirm --needed

# Setup the test user
RUN useradd --create-home --no-log-init --shell "/bin/${USERSHELL}" "${DEFAULT_USER}"
RUN install -dm755 /etc/sudoers.d/
RUN { \
    echo "Defaults:%${DEFAULT_USER} targetpw"; \
    echo "%${DEFAULT_USER} ALL=(ALL) NOPASSWD: ALL"; \
} > /etc/sudoers.d/20-xfce-test-user

ENV USER_HOME="/home/${DEFAULT_USER}"

# for makepkg
ENV PACKAGER="${DEFAULT_USER} <xfce4-dev@xfce.org>"
ENV BUILDDIR=/var/cache/makepkg-build/
RUN install -dm755 --owner=${DEFAULT_USER} ${BUILDDIR}

RUN runuser -u "${DEFAULT_USER}" -- git clone https://aur.archlinux.org/${PACMAN}-bin.git /tmp/${PACMAN}
RUN cd /tmp/${PACMAN} \
    && sudo runuser -u "${DEFAULT_USER}" -- makepkg --install --force --syncdeps --rmdeps --noconfirm --needed

# install more packages required for the next few steps
RUN runuser -u ${DEFAULT_USER} -- ${PACMAN} -S python-behave gsettings-desktop-schemas --noconfirm --needed

# needed for LDTP and friends
RUN /usr/bin/dbus-run-session /usr/bin/gsettings set org.gnome.desktop.interface toolkit-accessibility true

# copy in our scripts
COPY --chown=$DEFAULT_USER container_scripts /container_scripts
RUN chmod +x /container_scripts/*.sh /container_scripts/*.py

# xfce specific build dependencies and default panel plugins
RUN /container_scripts/build_time/install_packages-${TAG}.sh

# Install _all_ languages for testing
# RUN ${PACMAN} -Syu --noconfirm \
#  && ${PACMAN} -S transifex-client xautomation intltool \
#     opencv python-google-api-python-client \
#     python-oauth2client --noconfirm --needed

RUN /container_scripts/build_time/create_automate_langs.sh

# Group all repos here
RUN install -dm755 --owner=${DEFAULT_USER} /git

# Rather use my patched version
# TODO: Create an AUR package for ldtp2
# RUN cd git \
#  && git clone -b python3 https://github.com/schuellerf/ldtp2.git \
#  && cd ldtp2 \
#  && sudo pip3 install -e .

# ENV PKG_CONFIG_PATH="${PKG_CONFIG_PATH}${PKG_CONFIG_PATH:+:}/usr/local/lib/pkgconfig"
# RUN env PKG_CONFIG_PATH="$(pkg-config --variable=pc_path pkg-config):${PKG_CONFIG_PATH} \
#         /container_scripts/build_all-${TAG}.sh

# clean the install cache
RUN runuser -u ${DEFAULT_USER} -- ${PACMAN} -Sc --noconfirm

COPY behave /behave_tests

RUN mkdir /data

COPY xfce-test /usr/bin/

RUN chmod a+x /usr/bin/xfce-test && ln -s /usr/bin/xfce-test /xfce-test

COPY --chown=${DEFAULT_USER} .tmuxinator "${USER_HOME}/.tmuxinator"

COPY --chown=${DEFAULT_USER} extra_files/mimeapps.list "${USER_HOME}/.config/"

RUN install -dm755 --owner=${DEFAULT_USER} "${USER_HOME}/Desktop"

RUN ln --symbolic /data "${USER_HOME}/Desktop/data"

RUN ln --symbolic "${USER_HOME}/version_info.txt" "${USER_HOME}"/Desktop

# switch to the test-user
USER "${DEFAULT_USER}"

WORKDIR /data

CMD [ "/container_scripts/entrypoint.sh" ]
