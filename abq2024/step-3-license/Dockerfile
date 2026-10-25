FROM abq2024-tmp2

# Clean up any leftover bash history from the manual installation process.
RUN rm -f /root/.bash_history

# Copy the license server installation files to the image.
COPY SolidSQUAD_License_Servers /usr/SolidSQUAD_License_Servers

# Modify some of the installation files, install the license server, and crack.
RUN sed -i 's/INITSYSTEM="`detect_linux_init_system`"/INITSYSTEM="systemd"/g' /usr/SolidSQUAD_License_Servers/install_or_update.sh && \
    ln -s  /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib/ld-lsb.so.3 && \
    /usr/SolidSQUAD_License_Servers/install_or_update.sh

# Modify the license server configuration file.
RUN echo "LICENSE_SERVER_TYPE=flex" >> /usr/SIMULIA/EstProducts/2024/linux_a64/SMA/site/EstablishedProductsConfig.ini && \
    echo "FLEX_LICENSE_CONFIG=27800@localhost" >> /usr/SIMULIA/EstProducts/2024/linux_a64/SMA/site/EstablishedProductsConfig.ini

# Make "abaqus" command available in the terminal.
ENV PATH="$PATH:/var/DassaultSystemes/SIMULIA/Commands"

# Tell Abaqus to use gfortran as the Fortran compiler.
ENV ABQ_USUB_GFORTRAN=1

# Fix "decode() argument 'encoding' must be str, not None" in Edit Keywords and
# other Abaqus features. C.UTF-8 is the only UTF-8 locale available in Ubuntu
# 20.04 image, but it is not present in Abaqus's acceptable alias list (see
# /usr/SIMULIA/EstProducts/2024/linux_a64/SMA/Configuration/locale.txt [Alias]
# section). Abaqus would reset locale back to 'C' during startup otherwise.
# LANG provides the UTF-8 value, ABAQUS_KEEP_LOCALE=1 prevents Abaqus from
# resetting it to 'C'.
ENV LANG=C.UTF-8
ENV ABAQUS_KEEP_LOCALE=1

CMD systemctl start flexlmsrvssq && sleep infinity
