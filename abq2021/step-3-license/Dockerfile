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

# Fix encoding errors (e.g. "TypeError: unicode() argument 2 must be string,
# not None") when loading plugins in Abaqus CAE. CentOS 7 image ships with no
# LANG set and Python 2 leaves locale otherwise unset, causing Abaqus's plugin
# system to crash without a valid UTF-8 encoding. en_US.utf8 is the only UTF-8
# locale available in CentOS 7 and is present in Abaqus's acceptable alias list
# (see /usr/SIMULIA/EstProducts/2021/linux_a64/SMA/Configuration/locale.txt
# [Alias] section).
ENV LANG=en_US.utf8

# Entrypoint: start the FlexLM daemon, then exec user's command.
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sleep", "infinity"]
