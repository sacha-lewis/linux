#!/bin/bash

# Install libraries
sudo apt install sysbench glmark2

# Run CPU
sysbench cpu --threads=$(nproc) run

# run
glmark2