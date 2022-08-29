
flags = --dotfiles
packages = \
	cloudferro \
	functions \
	gdb \
	git \
	nvim \
	personal \
	tmux \
	vim \
	zsh \
	pgcli \
	i3

all:
	stow $(flags) $(packages)

clean:
	stow $(flags) -D $(packages)  2>/dev/null

