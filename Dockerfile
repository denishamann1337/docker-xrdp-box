FROM ubuntu:rolling
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y 
RUN apt-get install -y software-properties-common
#check if needed
#RUN apt-add-repository -y ppa:ubuntu-mate-dev/xenial-mate
RUN apt-get update -y
#RUN apt full-upgrade -y
#RUN apt-get dist-upgrade -y
RUN apt-get install -y bash wget curl unzip p7zip python python3 python-pip python3-pip gnome-session-flashback zsh openvpn sudo xrdp tigervnc-standalone-server inetutils-ping chromium-browser
RUN apt-get install -y mate-core mate-desktop-environment mate-notification-daemon
RUN apt-get install -y supervisor

ADD xrdp.conf /etc/supervisor/conf.d/xrdp.conf

# common downloads
RUN wget https://raw.githubusercontent.com/sormuras/bach/master/install-jdk.sh;chmod +x install-jdk.sh
RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
RUN wget -O swamp https://github.com/felixb/swamp/releases/latest/download/swamp_amd64;chmod +x swamp
RUN wget -O ideaIU-2019.2.1.tar.gz https://download.jetbrains.com/idea/ideaIU-2019.2.1.tar.gz;tar -xfz ideaIU-2019.2.1.tar.gz

# common installs
RUN dpkg -i session-manager-plugin.deb

EXPOSE 3389

# Allow all users to connect via RDP.
RUN sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini
RUN xrdp-keygen xrdp auto
RUN apt-get install -y vim

# Install Java.
RUN ./install-jdk.sh -f 12 --target ./jdk12
ENV PATH="${PATH}:./jdk12/bin"
# install AWS
RUN python3 -m pip install awscli

RUN apt-get autoclean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY gsettings.sh /gsettings.sh
COPY autostart.desktop /etc/xdg/autostart/autostart.desktop
RUN chmod +x /gsettings.sh

RUN useradd opal
RUN echo 'opal:opalpwd' | chpasswd

CMD ["/usr/bin/supervisord", "-n"]

# Set the locale
RUN locale-gen de_DE.UTF-8
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE:de
ENV LC_ALL de_DE.UTF-8
RUN update-locale LANG=de_DE.UTF-8
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime && dpkg-reconfigure -f noninteractive tzdata
#COPY cismet.png /cismet.png
