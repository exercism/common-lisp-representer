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

# Set reprsenter script as the ENTRYPOINT
ENTRYPOINT ["bin/generate.sh"]
