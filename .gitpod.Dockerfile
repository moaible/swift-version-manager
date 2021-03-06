FROM swift AS build

USER ROOT
FROM gitpod/workspace-full
COPY --from=build /usr/bin/swiftc /usr/bin/

# Install Swift dependencies
RUN sudo apt-get update -q && \
    sudo apt-get install -yq libtinfo5 \
        libcurl4-openssl-dev \
        libncurses5 \
        libpython2.7 \
        libatomic1 \
        libcurl4 \
        libxml2 \
        libedit2 \
        libsqlite3-0 \
        libc6-dev \
        binutils \
        libpython2.7 \
        tzdata \
        git \
        pkg-config \
    && sudo rm -rf /var/lib/apt/lists/*

# Install sourcekit-lsp dependencies
RUN sudo apt-get install -yq \
    libsqlite3-dev \
    libncurses5-dev \
    libncurses5

# Install Swift
RUN mkdir -p /home/gitpod/.swift && \
    cd /home/gitpod/.swift && \
    curl -fsSL https://swift.org/builds/swift-5.3-release/ubuntu1804/swift-5.3-RELEASE/swift-5.3-RELEASE-ubuntu18.04.tar.gz | tar -xzv
ENV PATH="$PATH:/home/gitpod/.swift/swift-5.3-RELEASE-ubuntu18.04/usr/bin"

# Install Ice
WORKDIR $HOME
RUN mkdir -p $HOME/ice && git clone https://github.com/jakeheis/Ice $HOME/ice
WORKDIR $HOME/ice
RUN swift build -c release
RUN sudo cp -f $HOME/ice/.build/release/ice /usr/local/bin

# Install sourcekite
WORKDIR $HOME
RUN mkdir -p $HOME/sourcekite && git clone https://github.com/vknabel/sourcekite $HOME/sourcekite
WORKDIR $HOME/sourcekite 
RUN swift build -c release
RUN sudo cp -f $HOME/sourcekite/.build/release/sourcekite /usr/local/bin

# Install sourcekit-lsp
RUN git clone https://github.com/apple/sourcekit-lsp $HOME/sourcekit-lsp
WORKDIR $HOME/sourcekit-lsp
RUN swift build \
    -Xcxx -I/home/gitpod/.swift/swift-5.3-RELEASE-ubuntu18.04/usr/lib/swift \
    -Xcxx -I/home/gitpod/.swift/swift-5.3-RELEASE-ubuntu18.04/usr/lib/swift/Block/
WORKDIR $HOME/sourcekit-lsp/Editors/vscode
RUN npm run createDevPackage

USER gitpod
