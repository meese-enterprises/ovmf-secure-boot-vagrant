#!/bin/bash
source /vagrant/lib.sh

# Install sbctl
go install -v github.com/foxboron/sbctl/cmd/sbctl@latest
