
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
	zsh

all:
	stow $(flags) $(packages)

clean:
	stow $(flags) -D $(packages)  2>/dev/null

