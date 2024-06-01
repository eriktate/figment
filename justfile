run-game:
	zig build run -Dmode=game

run-editor:
	zig build run -Dmode=editor

run-pipeline:
	zig build run -Dmode=pipeline

start-tmux:
	./tmux.sh
	tmux a
