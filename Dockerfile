# A minimalist linux distro
FROM alpine
# Do everything in the home directory
WORKDIR /root
# Install nginx and development tools, remove system openssl
RUN apk update && \
    apk del openssl && \
    apk add wget perl build-base linux-headers nginx
# Download a vulnerable OpenSSL source
RUN wget -O- --no-check-certificate 'https://www.openssl.org/source/openssl-1.0.1f.tar.gz' | tar xz
# Build OpenSSL from source and install it
RUN cd openssl-1.0.1f && \
    wget -O- --no-check-certificate 'https://raw.githubusercontent.com/embeddedartists/buildroot/master/package/openssl/openssl-004-musl-termios.patch' | patch -p1 && \
    ./config no-hw shared --prefix=/usr --openssldir=/usr/local/openssl && \
    make depend && \
    make ; \
    make install && \
    cd .. && \
    rm -rf openssl-1.0.1f /usr/local/openssl/man
# Do some cleanup
RUN apk del wget perl build-base linux-headers && \
    rm -rf /var/cache/apk/*
# Generate a self-signed certificate for nginx
RUN openssl req -x509 -newkey rsa:2048 -keyout /etc/nginx/cert.key -nodes -days 365 -subj '/C=FR/ST=Rhône Alpes/L=Grenoble/CN=localhost/emailAddress=test@example.com' -out /etc/nginx/cert.pem
# Configure nginx
ADD nginx.conf /etc/nginx/nginx.conf
# Create the directory for nginx.pid
RUN mkdir -p /run/nginx
# By default on this container, start nginx
CMD /usr/sbin/nginx
# Expose HTTPS port for the internal nginx server
EXPOSE 443
