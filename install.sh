#!/bin/bash

./script/install.pl mode=house start=test rebuild=1 path=../temp_house.conf
./script/install.pl mode=test start=test rebuild=1 path=../temp_house.conf