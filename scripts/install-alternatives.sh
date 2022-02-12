#!/usr/bin/env bash


update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 310 --slave /usr/bin/pip pip /usr/local/bin/pip3.10
update-alternatives --install /usr/bin/python python /usr/local/bin/python3.9 39   --slave /usr/bin/pip pip /usr/local/bin/pip3.9
update-alternatives --install /usr/bin/python python /usr/local/bin/python3.8 38   --slave /usr/bin/pip pip /usr/local/bin/pip3.8
update-alternatives --install /usr/bin/python python /usr/bin/python2.7 27
