FROM docker.io/frolvlad/alpine-glibc

# Install basic tools and edge packages
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
      bash git g++ gdb make cmake \
      neovim stow ripgrep fzf tmux zoxide \
      mandoc procps ncurses gnupg pass curl 

# Set the working directory
WORKDIR /root

# Setup dotfiles
RUN git clone https://github.com/infinage/infinage.git && \
    stow --no-folding --dir=/root/infinage --target=/root dotfiles && \
    chmod 700 /root/.gnupg && \
    cp -r /root/infinage/.password-store /root/.password-store 

# Clangd setup for LSP
RUN wget https://github.com/clangd/clangd/releases/download/21.1.0/clangd-linux-21.1.0.zip && \
    unzip clangd-linux-21.1.0.zip && \
    mv clangd_21.1.0/bin/clangd /usr/bin/clangd && \
    rm -rf clangd-linux-21.1.0.zip clangd_21.1.0 

# Neovim setup
RUN mkdir -p /root/.local/share/nvim/site/autoload && \
    cp /root/infinage/misc/plug.vim /root/.local/share/nvim/site/autoload && \
    nvim --headless +PlugInstall +qall > /dev/null 2>&1

# Default to Bash
CMD [ "bash" ]
