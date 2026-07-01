#!/bin/bash

# install
sudo apt install powerstat

# run and do 300 seconds of sampling
sudo powerstat

# more details about battery
upower -i $(upower -e | grep BAT)


sudo apt install powertop
sudo powertop