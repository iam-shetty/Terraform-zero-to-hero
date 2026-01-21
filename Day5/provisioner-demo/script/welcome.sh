#!/bin/bash
# A simple script to copied to the instace during file+remote exec demo
 set -e
echo "Welcome to the Provisioner Demo" | sudo tee /tmp/welcome_msg.txt
uname -a | sudo tee -a /tmp/welcome_msg.txt
cat /tmp/welcome_msg.txt

