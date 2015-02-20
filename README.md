# Derek Wyatt's Vim Configuration

Yup... it's a vim configuration.

To install it, do the following:

* Wipe out your `~/.vimrc` file and `~/.vim` directory (back up if you wish)
* `git clone https://github.com/derekwyatt/vim-config.git ~/.vim`
* `ln ~/.vim/vimrc ~/.vimrc`
* I use [Vundle](https://github.com/gmarik/Vundle.vim), so you'll have to install that into `~/.vim/bundle/Vundle.vim`.  You will probably also have to run `:VundleInstall` when you start up Vim as well.
* Start Vim

Occassionally plugins will get updates, and you should use the `:VundleUpdate` command to get those updates.
