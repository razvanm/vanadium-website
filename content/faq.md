---
title: FAQ
toc: true
---

# Who should consider using this Vanadium pre-release?

Anyone who's interested in learning what the system can do, or is excited about
the prospect of being an early adopter or contributor of what we hope will
become a comprehensive framework for building distributed applications and
multi-device UIs.

# Who should not consider using this Vanadium pre-release?

Anyone who needs to build a production quality system or application over the
next few months &mdash; although we believe our code is well tested, we expect
to continue to make changes to the core APIs and services as we learn from our
early adopters. Keeping up with such changes in a production environment is
likely to be problematic.

# Why did you choose the Go language?

We anticipated that we would be more productive using Go than one of the other
systems programming languages available to us.

# How does Vanadium relate to other Google open source projects?

Vanadium is an ongoing project, with a clear and ambitious long-term goal of
making it easier to build distributed multi-device apps and UIs. We'll use
whatever technology helps us meet those goals and design new technology whenever
we need to. We'll use whatever open source projects makes sense for us to use,
whether they originate from Google or anywhere else. We recognize that there is
overlap with many existing projects, but there is no single project that meets
our requirements or goals.

# Why did you build your own RPC system?

One of our design principles is to **put security first** and we wanted an RPC
protocol that has symmetrical end-to-end authentication, encryption, and the
ability to run through proxies without compromising that security. No existing
protocol that we are aware of meets these requirements, so we designed one. As
an example, our protocol allows a client and proxy to authenticate with each
other and for the client to authenticate with the server directly and
independently of the proxy. This allows an independent company to run a proxy
service for paying clients and service providers without having to implement its
own authentication scheme. All clients still authenticate directly with the
services they interact with and do not have to rely on the proxy service for the
validity of that authentication.

# Why did you build your own encoding format?

We wanted an encoding that can be used when the producer and consumer don't
necessarily share a common code base or 'stub library'. This loose coupling can
be in terms of space (e.g. a client and server implemented by two different code
bases and/or organizations) and time (e.g. a log file is written today, but read
10 years from now without access to the original code). This implies an encoding
that is language independent and self-describing; given a log file written using
our encoding, it should be possible to algorithmically construct the data types
needed to read that log file by examining that log file alone. Naturally we'd
like the encoding to be as efficient as possible, both in terms of space and
computational cost. We are not aware of any modern encoding format that meets
these requirements.

# Are there benchmarks for the Vanadium RPC system?

Benchmark code used to measure the performance of the Vanadium RPC stack is
[available on GitHub][benchmarks]. Results from the latest version of the
codebase are regularly measured and archived. Numbers from March, 2016 are
summarized in this table, but for the latest numbers [see this
page](/performance.html).

Benchmark      |Linux Desktop    |Raspberry Pi 2   | Nexus 5X Phone
---------------|:---------------:|:---------------:|:---------------:
[Connection][benchmark-connection]     |4 ms             | 130 ms          | 90 ms
[RPC (echo 1B)][benchmark-echo-1B] |0.4 ms/rpc       | 5 ms/rpc        | 4 ms/rpc

[benchmarks]: https://github.com/vanadium/go.ref/blob/master/runtime/internal/rpc/benchmark/benchmark_test.go
[benchmark-connection]: https://benchmarks.v.io/?q=v.io%2Fx%2Fref%2Fruntime%2Finternal%2Frpc%2Fbenchmark.BenchmarkConnectionEstablishment+uploader%3Adev.v.io%3Arole%3Avlab%3Aapp%3Abenchmarks%3A20160218
[benchmark-echo-1B]: https://benchmarks.v.io/?q=v.io%2Fx%2Fref%2Fruntime%2Finternal%2Frpc%2Fbenchmark.Benchmark____1B+uploader%3Adev.v.io%3Arole%3Avlab%3Aapp%3Abenchmarks%3A20160218
