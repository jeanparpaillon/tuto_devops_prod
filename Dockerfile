FROM ubuntu/ubuntu:24.04
 
 RUN apt-get update && \
     apt-get install -y python3 python3-pip sshpass && \
     pip3 install ansible && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/*
 