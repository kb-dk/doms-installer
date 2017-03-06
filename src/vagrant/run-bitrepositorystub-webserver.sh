#!/usr/bin/env bash

# Note:  server has been seen to crash under load.  Make more robust.
cd $HOME/bitrepository-quickstart/
python3 -m http.server 58709 &

