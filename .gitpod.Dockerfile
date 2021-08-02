FROM gitpod/workspace-full

RUN sudo apt-get update \
  && sudo apt-get install -y \
  && sudo rm -rf /var/lib/apt/lists/*

RUN brew install hub

ENV OOD_DEV_CONTAINER_PASS=password
