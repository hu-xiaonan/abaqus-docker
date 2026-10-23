FROM abq2025-tmp2

# Clean up any leftover bash history from the manual installation process.
RUN rm -f /root/.bash_history

# Copy the license server installation files to the image.
COPY SolidSQUAD_License_Servers /usr/SolidSQUAD_License_Servers

# Modify some of the installation files, install the license server, and crack.
RUN sed -i 's/INITSYSTEM="`detect_linux_init_system`"/INITSYSTEM="systemd"/g' /usr/SolidSQUAD_License_Servers/install_or_update.sh && \
    ln -s  /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib/ld-lsb.so.3 && \
    /usr/SolidSQUAD_License_Servers/install_or_update.sh

# Modify the license server configuration file.
# Delete stale keys first: plain "echo >>" appends leave duplicates and a
# leftover LICENSE_SERVER_TYPE=dsls shadows flex, so Standard checkout fails.
RUN INI=/usr/SIMULIA/EstProducts/2025/linux_a64/SMA/site/EstablishedProductsConfig.ini && \
    grep -q "^\[EstablishedProducts\]" "$INI" || sed -i '1i[EstablishedProducts]' "$INI" && \
    sed -i -e '/^LICENSE_SERVER_TYPE=.*/d' -e '/^FLEX_LICENSE_CONFIG=.*/d' "$INI" && \
    echo "LICENSE_SERVER_TYPE=flex" >> "$INI" && \
    echo "FLEX_LICENSE_CONFIG=27800@localhost" >> "$INI" && \
    cat "$INI"

# Entrypoint repairs the same config on every container start and (re)starts
# FlexLM, so `docker run ... abq2025 <cmd>` (which overrides CMD, see issue #9)
# can no longer leave lmgrd stopped (FLEXnet error -15,570).
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Make "abaqus" command available in the terminal.
ENV PATH="$PATH:/var/DassaultSystemes/SIMULIA/Commands"

# Tell Abaqus to use gfortran as the Fortran compiler.
ENV ABQ_USUB_GFORTRAN=1

# Abaqus CAE startup reads site env files through Python and expects a UTF-8 locale.
ENV LANG=C.UTF-8

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sleep", "infinity"]
