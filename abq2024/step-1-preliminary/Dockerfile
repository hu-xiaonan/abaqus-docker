FROM ubuntu:20.04

# Activate the systemd in the container using the following approach
#
# https://github.com/gdraheim/docker-systemctl-replacement/tree/master
#
# instead of the official approach (https://hub.docker.com/_/centos).
#
# Overwrite "/usr/bin/systemctl" with local "systemctl.py" script.
COPY systemctl.py /usr/bin/systemctl
RUN chmod +x /usr/bin/systemctl

# Dependencies:
# - openssh-client: Required for MPI.
# - libx11-6, libjpeg62, libxext6: Required for Abaqus CAE.
# - python2: Required for systemctl.py.
# - lsb-core: Required for the SolidSQUAD License Server.
#
# Note:
# tzdata may prompt for user input during installation.
# Setting DEBIAN_FRONTEND=noninteractive avoids this.
RUN apt-get update && \
    apt-get install -y --no-install-recommends gfortran openssh-client libx11-6 libjpeg62 libxext6 python2 && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y lsb-core && \
    rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
