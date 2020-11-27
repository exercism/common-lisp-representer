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

# Copy over the representer code
COPY --from=build /opt/representer/representer bin/
COPY bin/run.sh bin/

# Set representer script as the ENTRYPOINT
ENTRYPOINT ["bin/run.sh"]
