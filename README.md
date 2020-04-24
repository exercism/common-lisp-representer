# Common Lisp Representer

(_c.f._ For full details and up to date documentation on automated representers for Exercism see the [Automated Analysis][automated-analysis] repository.

> The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119][rfc-2119].


## Interface

(_.c.f._ [The Representer Interface][automated-analysis-representer-interface])

The `/opt/representer/bin/generate.sh` script that the docker image runs receives two parameters:

1. the test slug
2. the input/output directory namestring. This directory contains the submitted code.


The script *MUST* write the following files to the directory:

1. `representation.txt`: a normalized representation of the submitted code. All symbols must be replaced by gensyms.
2. `mapping.json`: maps the gensyms in `representation.txt` to the original symbols.

The output of the script *MAY* write the following files to the directory:

1. `representation.out`: any information that may want to view later for debugging.

The script *MAY* produce output to `stdout` and `stderr` which will be persisted for later.


[automated-analysis]: https://github.com/exercism/automated-analysis/
[automated-analysis-representer-interface]: https://github.com/exercism/automated-analysis/blob/master/docs/representers/interface.md
[rfc-2119]: https://www.ietf.org/rfc/rfc2119.txt

