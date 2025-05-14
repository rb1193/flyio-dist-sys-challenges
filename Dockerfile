FROM eclipse-temurin:21

WORKDIR /opt/app

RUN apt-get update && \
    apt-get install -y wget bzip2 git graphviz gnuplot ruby-full

RUN wget https://github.com/jepsen-io/maelstrom/releases/download/v0.2.4/maelstrom.tar.bz2 && \
    tar -xjf maelstrom.tar.bz2 && \
    rm maelstrom.tar.bz2