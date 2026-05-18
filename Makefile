.PHONY: install

install:
	sudo dnf install -y $(shell cat packages/base.txt | tr '\n' ' ')
