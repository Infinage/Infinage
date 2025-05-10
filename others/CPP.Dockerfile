FROM alpine:latest

# Install basic tools and add edge repo for latest packages
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache g++ vim make cmake curl clang-extra-tools openssh git tmux bash

WORKDIR /root

# Copy configs from GitHub
RUN mkdir -p ~/.vim/autoload ~/.vim/plugged ~/.config/clangd && \
    curl -fLo ~/.config/clangd/config.yaml \
    https://raw.githubusercontent.com/Infinage/Infinage/main/others/.clangd && \
    curl -fLo ~/.vimrc \
    https://raw.githubusercontent.com/Infinage/Infinage/main/others/.vimrc && \
    curl -fLo ~/.tmux.conf \
    https://raw.githubusercontent.com/Infinage/Infinage/main/others/.tmux.conf

# Setup minimal .bashrc
RUN echo 'export TERM=xterm-256color' > ~/.bashrc

# Install Vim plugins (optional - auto on first run too)
RUN vim -Es -u ~/.vimrc -i NONE -c "PlugInstall" -c "qa" || true

# Run Bash interactively
CMD [ "bash" ]
