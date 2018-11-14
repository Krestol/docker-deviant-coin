FROM ubuntu:18.10
MAINTAINER kotik <obrbkru@apriorit.com>

#install custom packages
RUN apt-get -q update

#install libdb4.8
#--software-properties-common for adding add-apt-repository
RUN apt-get install -y software-properties-common && add-apt-repository -y ppa:bitcoin/bitcoin && apt-get update
RUN apt-get install -y libdb4.8-dev libdb4.8++-dev
#--remove software-properties-common because it install openssl with wrong version
RUN apt-get remove -y software-properties-common

#install dependencies
RUN apt-get install -y build-essential libtool autotools-dev autoconf pkg-config libevent-dev automake
RUN apt-get install -y libboost-all-dev
RUN apt-get install -y git

#Download and build Deviant coin from branch code_correction
RUN git clone https://github.com/Deviantcoin/Source.git && cd ./Source && git checkout code_correction

#build openssl, PIVX support just openssl 1.0
RUN apt-get install -y wget
RUN wget https://www.openssl.org/source/openssl-1.0.1f.tar.gz && tar xf openssl-1.0.1f.tar.gz 
RUN cd openssl-1.0.1f && ./config && make && make install_sw

#configure
#install bsdmainutils for fixing "hexdump is required for tests"
RUN apt-get install -y bsdmainutils 
RUN cd ./Source && chmod +x autogen.sh && ./autogen.sh && \
export LDFLAGS=-L/usr/local/ssl/lib && export CPPFLAGS=-I/usr/local/ssl/include && export PKG_CONFIG_PATH=/usr/local/ssl/lib/pkgconfig &&\
./configure --with-gui=no --with-unsupported-ssl

#build
RUN chmod +x ./Source/src/leveldb/build_detect_platform && chmod +x ./Source/share/genbuild.sh && make

#run daemon
WORKDIR /chain
VOLUME ["/chain"]
CMD cd ~ && mkdir ./chain && ./Source/src/deviantd -datadir=/chain -gen -staking
#command to run container docker run -d -v ~/chain:/chain
#it mounts host folder ~/chain to container

