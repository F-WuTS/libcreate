FROM debian:bookworm

RUN apt update && \
    apt install -y \
        build-essential cmake git file tree \
        libboost-system-dev libboost-thread-dev \
        libgtest-dev googletest && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /libcreate
COPY . .

WORKDIR /libcreate/build
ENTRYPOINT ["/bin/bash", "/libcreate/ci/entrypoint.sh"] 
