## Build the builder image
FROM daewok/sbcl:alpine AS build
RUN apk update && apk upgrade

# Set working directory
WORKDIR /opt/representer
env HOME /opt/representer

# Pull down the latest Quicklisp
ADD https://beta.quicklisp.org/quicklisp.lisp quicklisp/

# install quicklisp
COPY build/install-quicklisp.lisp build/
RUN sbcl --script build/install-quicklisp.lisp

# build the application
COPY build/build.lisp build/
COPY src quicklisp/local-projects/representer
RUN sbcl --script ./build/build.lisp

## Build the runtime image
FROM alpine
WORKDIR /opt/representer

# Copy over the test runner
COPY --from=build /opt/representer/representer bin/
COPY bin/run.sh bin/

# Pull down the tooling connector binary and make it executable.
ADD https://github.com/exercism/tooling-webserver/releases/latest/download/tooling_webserver /usr/local/bin
RUN chmod +x /usr/local/bin/tooling_webserver

# Set reprsenter script as the ENTRYPOINT
ENTRYPOINT ["bin/run.sh"]
