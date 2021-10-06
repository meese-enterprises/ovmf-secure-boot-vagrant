#!/bin/bash
source /vagrant/lib.sh

# install go.
# see https://golang.org/dl/
# see https://golang.org/doc/install
artifact_url=https://golang.org/dl/go1.17.1.linux-amd64.tar.gz
artifact_sha=dab7d9c34361dc21ec237d584590d72500652e7c909bf082758fb63064fca0ef
artifact_path="/tmp/$(basename $artifact_url)"
wget -qO $artifact_path $artifact_url
if [ "$(sha256sum $artifact_path | awk '{print $1}')" != "$artifact_sha" ]; then
    echo "downloaded $artifact_url failed the checksum verification"
    exit 1
fi
rm -rf /usr/local/go
install -d /usr/local/go
tar xf $artifact_path -C /usr/local/go --strip-components 1
rm $artifact_path

# add go to all users path.
cat >/etc/profile.d/go.sh <<'EOF'
#[[ "$-" != *i* ]] && return
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"
EOF
