# Simple Makefile for common tasks

.PHONY: install healthcheck setup-ssh macos

install:
	./install.sh

healthcheck:
	./scripts/healthcheck.sh

setup-ssh:
	./scripts/setup-ssh.sh

macos:
	./scripts/macos-setup.sh


