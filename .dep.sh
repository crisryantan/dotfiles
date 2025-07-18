# Based on Paul Iris' install-deps.sh
mkdir -p ~/.bin

# https://github.com/rupa/z
cd ~/.bin
if [ ! -d "z" ]; then
	git clone https://github.com/rupa/z.git
	chmod +x ~/.bin/z/z.sh
else
	echo "z already installed, updating..."
	cd z && git pull origin master && cd ..
fi

if [ ! -x $(which ruby) ]; then
	echo 'Ruby not installed. Install ruby and re-run this script.'
else
	# janus vim
	cd ~/
	if [ ! -d ".vim" ]; then
		curl -Lo- https://bit.ly/janus-bootstrap | bash
	else
		echo "Janus vim already installed, updating..."
		cd ~/.vim && rake update && cd ~/
	fi

	mkdir -p ~/.janus
	cd ~/.janus

	# Clone vim plugins only if they don't exist
	[ ! -d "ack.vim" ] && git clone https://github.com/mileszs/ack.vim.git
	[ ! -d "vim-jade" ] && git clone https://github.com/digitaltoad/vim-jade.git
	[ ! -d "emmet-vim" ] && git clone https://github.com/mattn/emmet-vim.git
	[ ! -d "jsoncodecs.vim" ] && git clone https://github.com/michalliu/jsoncodecs.vim.git
	[ ! -d "sourcebeautify.vim" ] && git clone https://github.com/michalliu/sourcebeautify.vim.git
	[ ! -d "jsruntime.vim" ] && git clone https://github.com/michalliu/jsruntime.vim.git
	[ ! -d "Align" ] && git clone https://github.com/vim-scripts/Align.git
	[ ! -d "vim-cucumber" ] && git clone https://github.com/tpope/vim-cucumber.git
	[ ! -d "neocomplete.vim" ] && git clone https://github.com/Shougo/neocomplete.vim.git

	[ ! -d "gruvbox" ] && git clone https://github.com/morhetz/gruvbox.git
	[ ! -d "vim-kolor" ] && git clone https://github.com/zeis/vim-kolor.git
	[ ! -d "vim-hemisu" ] && git clone https://github.com/noahfrederick/vim-hemisu.git
	[ ! -d "TuttiColori-Colorscheme" ] && git clone https://github.com/vim-scripts/TuttiColori-Colorscheme.git

	echo "All vim plugins checked/installed."

	# Back to .dotfiles folder
	cd ~/.dotfiles
	source bootstrap.sh
fi
