FROM ubuntu:14.04
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
RUN apt-get install -y build-essential libtool autotools-dev autoconf libssl-dev pkg-config libevent-dev automake
RUN apt-get install -y libboost-all-dev
RUN apt-get install -y git

#Download and build Deviant coin from branch code_correction
RUN git clone https://github.com/Deviantcoin/Source.git && cd ./Source && git checkout code_correction

#configure
#install bsdmainutils for fixing "hexdump is required for tests"
RUN apt-get install -y bsdmainutils 
RUN cd ./Source && chmod +x autogen.sh && ./autogen.sh && ./configure --with-gui=no

#patch chainparam.cpp for changing zerocoinV2 block and seeds
RUN git config --global user.name obrbkru && git config --global user.email obr@bk.ru && \
git clone https://github.com/apriorit/docker-deviant-coin.git && \
cp ./docker-deviant-coin/resources/chainparam.cpp.diff ./Source && \
cd ./Source && git apply *.diff
#build
RUN chmod +x ./Source/src/leveldb/build_detect_platform && chmod +x ./Source/share/genbuild.sh && cd ./Source && make

#run daemon
WORKDIR /
CMD cp ./docker-deviant-coin/resources/deviant.conf /chain && ./Source/src/deviantd -datadir=/chain -gen -staking
#command to run container: "mkdir -p ~/chain && sudo docker run -d -v ~/chain:/chain apriorit/docker-deviant-coin"
#it mounts host folder ~/chain to container
#to create network:
#docker network create \
#  --driver=bridge \
#  --subnet=10.100.6.0/16 \
#  --ip-range=10.100.6.0/24 \
#  --gateway=10.100.6.1 \
#  br0
#after this, it is posible to run docker in this network with option --net, example: "sudo docker run -d --net=br0 -v ~/chain:/chain apriorit/docker-deviant-coin"

