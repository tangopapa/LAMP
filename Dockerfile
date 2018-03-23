FROM debian:stretch-slim
LABEL maintainer="tom@frogtownroad.com"

ENV user=dockter-tom
RUN groupadd -r ${user} && useradd -r -l -M ${user} -g ${user} 

Run bash build-lamp.sh

