# BUILDER
FROM ubuntu:latest as builder

ARG checkout="master"
ARG git_url="https://github.com/bitcoin/bitcoin"

RUN apt update && apt install -y \
    build-essential \
    cmake \
    git \
    libboost-all-dev \
    libssl-dev \
    libzmq3-dev \
    pkg-config \
    build-essential \
    libtool \
    autotools-dev \
    automake \
    pkg-config \
    bsdmainutils \
    python3 \
    libevent-dev \
    libboost-dev \
    libsqlite3-dev \
    libminiupnpc-dev \
    libnatpmp-dev \
    libzmq3-dev \
    systemtap-sdt-dev

WORKDIR /src

# Git clone a specific tag
RUN rm -rf /src
RUN git clone ${git_url} /src
RUN git checkout ${checkout} -b local/${checkout}

RUN ./autogen.sh && ./configure --without-gui && make -j $(nproc) && make install

# FINAL IMAGE
FROM ubuntu:latest as final

RUN apt update && apt upgrade -y
RUN apt install -y \
    libminiupnpc-dev \
    libnatpmp-dev \
    libzmq3-dev \
    systemtap-sdt-dev \
    libevent-dev

COPY --from=builder /usr/local/bin/bitcoind /usr/local/bin/
COPY --from=builder /usr/local/bin/bitcoin-cli /usr/local/bin/

CMD ["bitcoind"]
