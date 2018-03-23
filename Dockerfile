FROM debian:stretch-slim
LABEL maintainer="tom@frogtownroad.com"

ENV user=dockter-tom
RUN groupadd -r ${user} && useradd -r -l -M ${user} -g ${user} 

WORKDIR /opt

RUN build-lamp.sh

EXPOSE 80 443 3306
ENTRYPOINT ["/bin/bash"]
