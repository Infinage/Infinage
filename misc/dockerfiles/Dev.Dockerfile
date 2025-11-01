FROM alpine:latest

# Install basic tools and edge packages
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache bash git g++ gdb \
    clang-extra-tools neovim stow ripgrep \
    fzf tmux zoxide make cmake mandoc

# Clone dotfiles and apply with stow
WORKDIR /root
RUN git clone https://github.com/infinage/infinage.git && \
    cd infinage && stow dotfiles

# Install vim-plug manually
RUN mkdir -p /root/.local/share/nvim/site/autoload && \
    cp /root/infinage/misc/plug.vim /root/.local/share/nvim/site/autoload/

# Install Neovim plugins silently
RUN nvim --headless +PlugInstall +qall > /dev/null 2>&1

# Default to Bash
CMD [ "bash" ]
