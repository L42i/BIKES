#!/bin/bash

killall sclang || true
killall scsynth || true
killall p2psc || true

p2psc &
sclang reduced.scd