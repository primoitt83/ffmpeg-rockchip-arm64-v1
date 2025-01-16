FROM arm64v8/ubuntu:focal as build-ffmpeg

LABEL maintainer="primoitt83@gmail.com"

## Copy packages and files
COPY ${PWD}/ffmpeg.sh / 
RUN chmod +x /ffmpeg.sh && /ffmpeg.sh

##########################
## Build the release image.
FROM arm64v8/ubuntu:focal

LABEL maintainer="primoitt83@gmail.com"

## Copy packages and files
RUN mkdir /root/deb
COPY --from=build-ffmpeg /root/deb/. /root/deb
COPY ${PWD}/get-videos.sh / 

## install
COPY ${PWD}/install.sh / 
RUN chmod +x /install.sh && /install.sh

RUN \
    mkdir -p /opt/data && \
    mkdir -p /opt/data/hls && \
    mkdir -p /www

COPY ${PWD}/static /www
COPY ${PWD}/index.html /www/static 
COPY ${PWD}/index.html /opt/data 
COPY ${PWD}/index.html /opt/data/hls

RUN \
    chown nobody:65534 -R /opt/data && \
    chown nobody:65534 -R /www && \
    chmod 775 -R /opt/data && \
    chmod 775 -R /www

COPY ${PWD}/nginx.conf /etc/nginx/nginx.conf

## permissions
RUN chmod +x /usr/bin/ffmpeg
RUN chmod +x /usr/bin/ffprobe

CMD nginx