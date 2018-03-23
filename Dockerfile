FROM debian:stretch-slim
LABEL maintainer="tom@frogtownroad.com"

ENV user=dockter-tom
RUN groupadd -r ${user} && useradd -r -l -M ${user} -g ${user} 

WORKDIR .
COPY build-lamp.sh .
RUN chmod +x build-lamp.sh
RUN /bin/bash ./build-lamp.sh

EXPOSE 80 443 3306
CMD ["service apache2 restart"]
