#!/bin/bash

./script/install.pl mode=house start=test rebuild=1 path=./house.conf_src
./script/install.pl mode=test start=test rebuild=1 path=./house.conf_src