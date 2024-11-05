#!/usr/bin/env bash

tmux bind-key H run-shell "tmux popup -y 10 -w 100 -h 20 -E $HOME/bin/tmux-cht-sh.sh"
