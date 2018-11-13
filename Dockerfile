FROM ubuntu:18.10
MAINTAINER kotik <obrbkru@apriorit.com>

#install custom packages
RUN apt-get -q update
RUN apt-get install -y software-properties-common && add-apt-repository -y ppa:bitcoin/bitcoin
RUN apt-get update && apt-get install -y build-essential libtool autotools-dev autoconf pkg-config libssl-dev libevent-dev automake
RUN apt-get install -y libboost-all-dev
RUN apt-get install -y libdb4.8-dev libdb4.8++-dev
RUN apt-get install -y git

#Download and build Deviant coin from branch code_correction
RUN git clone https://github.com/Deviantcoin/Source.git && cd ./Source && git checkout code_correction

#configure
#install bsdmainutils for fixing "hexdump is required for tests"
RUN apt-get install -y bsdmainutils 
RUN cd ./Source && chmod +x autogen.sh && ./autogen.sh && ./configure --with-gui=no

#build
RUN chmod +x ./Source/src/leveldb/build_detect_platform && ./Source/share/genbuild.sh && make

#run daemon
WORKDIR /chain
VOLUME ["/chain"]
CMD cd ~ && mkdir ./chain && ./Source/src/deviantd -datadir=/chain -gen -staking
#command to run container docker run -d -v ~/chain:/chain
#it mounts host folder ~/chain to container

