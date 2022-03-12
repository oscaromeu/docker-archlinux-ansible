FROM archlinux/archlinux:base
LABEL maintainer="Oscar Romeu"

ENV pip_packages "ansible cryptography"

# Install dependencies.
RUN pacman -Syu --noconfirm \
    sudo net-tools gcc python3 python-pip
# Clean (purge) the repo cache
RUN pacman --noconfirm -Scc && rm -rf /var/lib/pacman/sync/* && \
    #&& rm -Rf /usr/share/doc && rm -Rf /usr/share/man && \
    # Purge logs
    rm -rf /var/log/* /var/run/log/journal

# Upgrade pip to latest version.
RUN pip3 install --upgrade pip

# Install Ansible via pip.
RUN pip3 install $pip_packages


# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Make sure systemd doesn't start agettys on tty[1-6].
RUN rm -f /lib/systemd/system/multi-user.target.wants/getty.target

# Without this, init won't start the enabled services. Starting the services
# fails with one of:
#     Failed to get D-Bus connection: Operation not permitted
#     System has not been booted with systemd as init system (PID 1). Can't operate.
#     Failed to connect to bus: No such file or directory
VOLUME [ "/sys/fs/cgroup", "/run" ]

# Start via systemd
CMD ["/usr/lib/systemd/systemd"]