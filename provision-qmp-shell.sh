#!/bin/bash
source /vagrant/lib.sh

# Install qmp-shell
go install -v github.com/0xef53/qmp-shell@latest

# Copy to the host
install -d /vagrant/tmp
install -m 555 ~/go/bin/qmp-shell /vagrant/tmp
