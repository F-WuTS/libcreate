FROM ubuntu:24.04

RUN apt update && \
    apt install -y \
        build-essential cmake file \
        libboost-system-dev libboost-thread-dev \
        libgtest-dev googletest && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /libcreate
COPY . .

WORKDIR /libcreate/build
RUN cmake -B /libcreate/build -S /libcreate -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-Werror" && \
    cmake --build /libcreate/build --config Release && \
    ctest -C Release --output-on-failure && \
    cpack --build /libcreate/build -G DEB
