#!/bin/bash
source /vagrant/lib.sh

# Install go
# REF: https://go.dev/doc/install
artifact_url="https://go.dev/dl/go1.22.6.linux-amd64.tar.gz"
artifact_sha="999805bed7d9039ec3da1a53bfbcafc13e367da52aa823cb60b68ba22d44c616"
artifact_path="/tmp/$(basename $artifact_url)"
wget -qO $artifact_path $artifact_url
if [ "$(sha256sum $artifact_path | awk '{print $1}')" != "$artifact_sha" ]; then
  echo "[-] ERROR: Downloaded artifact $artifact_url failed the checksum verification!"
  exit 1
fi

rm -rf /usr/local/go
install -d /usr/local/go
tar xf $artifact_path -C /usr/local/go --strip-components 1
rm $artifact_path

# Add go to path for all users
cat >/etc/profile.d/go.sh <<"EOF"
#[[ "$-" != *i* ]] && return
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"
EOF
