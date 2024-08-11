#!/bin/bash
session=figment

tmux new -d -s $session
tmux new-window -t $session:1
tmux new-window -t $session:2
tmux send-keys -t figment:0 'nvim src/editor.zig' Enter
tmux send-keys -t figment:1 'just run-editor'
tmux select-window -t $session:0
tmux a
