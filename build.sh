#!/usr/bin/env bash
docker build -t timlinux/flask-hello-world:latest flask_app
docker push timlinux/flask-hello-world:latest

