#!/usr/bin/env bash
systemctl --user enable podman.socket
systemctl --user start podman.socket
