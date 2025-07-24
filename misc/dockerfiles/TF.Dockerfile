FROM docker.io/tensorflow/build:2.20-python3.12

# Install basic tools
RUN apt-get update && \
    apt-get install -y openssh-server stow ripgrep clangd-18 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download neovim appimage to /usr/bin/nvim
WORKDIR /tmp
RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz && \
    tar xzf nvim-linux-x86_64.tar.gz && \
    mv nvim-linux-x86_64 /usr/local/share/nvim && \
    ln -s /usr/local/share/nvim/bin/nvim /usr/local/bin/nvim && \
    rm -rf nvim-linux64*

# Clone dotfiles and apply with stow
WORKDIR /root
RUN git clone https://github.com/infinage/infinage.git && \
    cd infinage && stow --ignore='^\.bashrc$' dotfiles && \
    echo "alias nv='nvim'" >> ~/.bashrc && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 100 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-18 100

# Install vim-plug manually
RUN mkdir -p /root/.local/share/nvim/site/autoload && \
    cp /root/infinage/misc/plug.vim /root/.local/share/nvim/site/autoload/

# Install Neovim plugins silently
RUN nvim --headless +PlugInstall +qall > /dev/null 2>&1

# Default to Bash
CMD [ "bash" ]
