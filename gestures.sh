#!/bin/sh

sudo apt install ruby libinput-tools
sudo gem install fusuma



mkdir -p ~/.config/fusuma
nano ~/.config/fusuma/config.yml

# add input to group
sudo gpasswd -a $USER input


#swipe:
#  3:
#    up:
#      command: pactl set-sink-volume @DEFAULT_SINK@ +5%
#    down:
#      command: pactl set-sink-volume @DEFAULT_SINK@ -5%




# auto start
# system settings -> autostart
which fusuma
# eg /usr/local/bin/fusuma

