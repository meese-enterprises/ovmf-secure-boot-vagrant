#!/bin/bash
source /vagrant/lib.sh

# Install go-uefi
go install -v github.com/foxboron/go-uefi/cmd/efianalyze@latest
