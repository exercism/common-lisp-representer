FROM clfoundation/sbcl:2.1.5-alpine3.13 AS build
RUN apk --no-cache add curl

# Set working directory
WORKDIR /opt/representer
ENV HOME=/opt/representer

# Pull down the latest Quicklisp
RUN mkdir build && curl https://beta.quicklisp.org/quicklisp.lisp -o build/quicklisp.lisp

# Install quicklisp
COPY build/install-quicklisp.lisp build/
RUN sbcl --script build/install-quicklisp.lisp

# Build the application
COPY build/build.lisp build/
COPY src quicklisp/local-projects/representer
RUN sbcl --script ./build/build.lisp

# Build the runtime image
FROM alpine:3.13
WORKDIR /opt/representer

# Copy over the representer code
COPY --from=build /opt/representer/bin/ bin/
COPY bin/run.sh bin/

# Set representer script as the ENTRYPOINT
ENTRYPOINT ["bin/run.sh"]
