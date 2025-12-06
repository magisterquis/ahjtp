#!/bin/bash
#
# user-data.sh
# Victim setup file
# By J. Stuart McMurray
# Created 20251130
# Last Modified 20251204

set -x
set -euo pipefail

VICTIM_USER=victim

# Add our non-root user.
groupadd docker
useradd -m -s /bin/bash -G docker         $VICTIM_USER
mkdir                               /home/$VICTIM_USER/.ssh
cp       /root/.ssh/authorized_keys /home/$VICTIM_USER/.ssh
chmod    0700                       /home/$VICTIM_USER/.ssh
chmod    0600                       /home/$VICTIM_USER/.ssh/authorized_keys
chown -R $VICTIM_USER:$VICTIM_USER  /home/$VICTIM_USER/.ssh
echo "$VICTIM_USER ALL=NOPASSWD:ALL" > /etc/sudoers

# Add swap.
SWAPFILE=/swapfile
dd if=/dev/zero of=$SWAPFILE bs=1024 count=$((2*1024*1024))
chmod 600 $SWAPFILE
mkswap $SWAPFILE
swapon $SWAPFILE
cat >>/etc/fstab <<_eof
# Swap file created on $(date)
$SWAPFILE       none    swap    sw      0       0
_eof

# Update ALL the things.
export DEBIAN_FRONTEND=noninteractive
for act in update upgrade dist-upgrade autoremove; do
        apt-get -y "$act"
done

# Install docker.  Copied from https://docs.docker.com/engine/install/debian/
apt-get -y update
apt-get -y install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
apt-get -y update
apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker run --rm hello-world

# Start the container going
TMPF=$(mktemp)
openssl base64 -d <<_eof |
m4_paste(m4_compose_b64)m4_dnl
_eof
docker compose          \
        -f -            \
        up              \
        --build         \
        --no-log-prefix \
        --quiet-build   |
tee "$TMPF"
docker system prune -f -a --volumes
CURL_COMMANDS=/home/$VICTIM_USER/curl_commands
awk '/Curl Commands for Access/,/Adjust as needed/' "$TMPF" >"$CURL_COMMANDS"
echo "Curl commands for access are in $CURL_COMMANDS"

# vim: ft=sh
