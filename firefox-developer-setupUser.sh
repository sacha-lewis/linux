#!/usr/bin/env bash

/opt/firefox-developer/firefox -CreateProfile dev-edition

# this creates ~/.mozilla/firefox/<random>.dev-edition/

sudo nano /usr/share/applications/firefox-developer.desktop

# change this line
Exec=/opt/firefox-developer/firefox -P dev-edition -no-remote

