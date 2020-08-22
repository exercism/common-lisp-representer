FROM daewok/sbcl:alpine
RUN apk update && apk upgrade

# Set working directory
WORKDIR /opt/representer
env HOME /opt/representer

# Pull down the latest Quicklisp
ADD https://beta.quicklisp.org/quicklisp.lisp src/

# install quicklisp
COPY src/ src/
RUN sbcl --script ./src/install-quicklisp.lisp

# build the application
COPY src/ src/
RUN sbcl --script ./src/build.lisp

# Copy over the test runner
COPY bin/generate.sh bin/

# Pull down the tooling connector binary
ADD https://github.com/exercism/local-tooling-webserver/releases/latest/download/exercism_local_tooling_webserver /usr/local/bin/
# Make the binary executable
RUN chmod +x /usr/local/bin/exercism_local_tooling_webserver

# Set reprsenter script as the ENTRYPOINT
ENTRYPOINT ["bin/generate.sh"]
