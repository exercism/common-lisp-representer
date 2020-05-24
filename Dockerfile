FROM daewok/sbcl:alpine
RUN apk update && apk upgrade

# Set working directory
WORKDIR /opt/representer
env HOME /opt/representer

# Pull down the latest Quicklisp
ADD https://beta.quicklisp.org/quicklisp.lisp src/

# install quicklisp and other dependencies
RUN sbcl --load src/quicklisp.lisp \
         --eval '(quicklisp-quickstart:install)' \
         --eval '(ql:quickload "yason")' \
         --quit

# Copy over the test runner
COPY bin/generate.sh bin/
COPY src/ src/

# Set reprsenter script as the ENTRYPOINT
ENTRYPOINT ["bin/generate.sh"]
