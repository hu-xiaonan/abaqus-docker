FROM centos:7

# Activate the systemd in the container using the following approach
#
# https://github.com/gdraheim/docker-systemctl-replacement/tree/master
#
# instead of the official approach (https://hub.docker.com/_/centos).
#
# Overwrite "/usr/bin/systemctl" with local "systemctl.py" script.
COPY systemctl.py /usr/bin/systemctl
RUN chmod +x /usr/bin/systemctl

# Install the necessary packages.
#
# Switch to the Aliyun repository since the default repository can be
# inaccessible in China.
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo && \
    yum install -y sudo dos2unix perl libX11 libjpeg libXext gcc-gfortran

CMD ["sleep", "infinity"]
