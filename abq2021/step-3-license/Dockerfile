FROM abq2021-tmp2

# Clean up any leftover bash history from the manual installation process.
RUN rm -f /root/.bash_history

# Copy the license server installation files to the image.
COPY SolidSQUAD_License_Servers /usr/SolidSQUAD_License_Servers

# Modify some of the installation files, install the license server, and crack.
RUN sed -i 's/INITSYSTEM="`detect_linux_init_system`"/INITSYSTEM="systemd"/g' /usr/SolidSQUAD_License_Servers/install_or_update.sh && \
    ln -s /usr/lib64/ld-linux-x86-64.so.2 /lib/ld-lsb.so.3 && \
    /usr/SolidSQUAD_License_Servers/install_or_update.sh && \
    sed -i 's/license_server_type=DSLS/license_server_type=FLEXNET/' /usr/SIMULIA/EstProducts/2021/linux_a64/SMA/site/custom_v6.env && \
    sed -i 's/dsls_license_config="\/var\/DassaultSystemes\/Licenses\/DSLicSrv.txt"/abaquslm_license_file="27800@localhost"/' /usr/SIMULIA/EstProducts/2021/linux_a64/SMA/site/custom_v6.env

# Make "abaqus" command available in the terminal.
ENV PATH="$PATH:/var/DassaultSystemes/SIMULIA/Commands"

# Start the license server and keep the container running.
CMD systemctl start flexlmsrvssq && sleep infinity
