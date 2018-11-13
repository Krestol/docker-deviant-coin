FROM ubuntu:16.10
MAINTAINER kotik <obrbkru@apriorit.com>

#install custom packages
RUN apt-get install software-properties-common && add-apt-repository -y ppa:bitcoin/bitcoin
RUN apt-get -q update && apt-get install build-essential libtool autotools-dev autoconf pkg-config libssl-dev libevent-dev automake
RUN apt-get install libboost-all-dev
RUN apt-get install libdb4.8-dev libdb4.8++-dev
RUN apt-get install git

#Download and build Deviant coin from branch code_correction
RUN git clone https://github.com/Deviantcoin/Source.git && git checkout code_correction

#configure
RUN cd ./Source && chmod +x autogen.sh && ./autogen.sh && ./configure --with-gui=no

#build
RUN chmod +x ./src/leveldb/build_detect_platform && ./share/genbuild.sh && make

#run daemon
RUN cd .. && mkdir ./chain
RUN ./Source/src/deviantd -datadir=./chain -gen -staking
