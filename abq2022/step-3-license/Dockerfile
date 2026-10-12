FROM abq2022-tmp2

# Clean up any leftover bash history from the manual installation process.
RUN rm -f /root/.bash_history

# Copy the license server installation files to the image.
COPY SolidSQUAD_License_Servers /usr/SolidSQUAD_License_Servers

# Modify some of the installation files, install the license server, and crack.
RUN sed -i 's/INITSYSTEM="`detect_linux_init_system`"/INITSYSTEM="systemd"/g' /usr/SolidSQUAD_License_Servers/install_or_update.sh && \
    ln -s /usr/lib64/ld-linux-x86-64.so.2 /lib/ld-lsb.so.3 && \
    /usr/SolidSQUAD_License_Servers/install_or_update.sh

# Modify the license server configuration file.
RUN echo "LICENSE_SERVER_TYPE=flex" >> /usr/SIMULIA/EstProducts/2022/linux_a64/SMA/site/EstablishedProductsConfig.ini && \
    echo "FLEX_LICENSE_CONFIG=27800@localhost" >> /usr/SIMULIA/EstProducts/2022/linux_a64/SMA/site/EstablishedProductsConfig.ini

# Make "abaqus" command available in the terminal.
#
# Note: My Abaqus 2022 installer creates "abq" symlink instead of "abaqus", so
# this symlink is created here to guarantee "abaqus" command is available.
RUN if [ ! -e /var/DassaultSystemes/SIMULIA/Commands/abaqus ]; then \
        ln -s /var/DassaultSystemes/SIMULIA/Commands/abq2022 /var/DassaultSystemes/SIMULIA/Commands/abaqus; \
    fi
ENV PATH="$PATH:/var/DassaultSystemes/SIMULIA/Commands"

CMD systemctl start flexlmsrvssq && sleep infinity
