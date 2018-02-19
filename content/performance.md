= yaml =
title: Vanadium Performance
toc: true
= yaml =

Performance of the Vanadium APIs is measured with microbenchmarks.
[benchmarks.v.io] records these results at various snapshots of the codebase
and on  multiple platforms. Since the total number of benchmarks served by
[benchmarks.v.io] is somewhat overwhelming, this page lists out a small subset
that can be considered representative of Vanadium.

The numbers below are for using the Go API. Benchmarks for other languages
(Java in particular) are not integrated into the flow of continuous measurement
yet, but are intended to be.

All the numbers are currently one click away. We hope to restructure this page
to embed live results to avoid that one click in the future.

# RPC
In all the benchmarks here, network round-trip time is zero. Thus, when RPCs
are executed 'in the wild', network round-trip time must be added.

## Connection Establishment

Results: <a href="https://benchmarks.v.io/?q=v.io%2Fx%2Fref%2Fruntime%2Finternal%2Frpc%2Fbenchmark.BenchmarkConnectionEstablishment+uploader%3Avlab#">v.io/x/ref/runtime/internal/rpc/benchmark.BenchmarkConnectionEstablishment</a>

Establishment of a mutually authenticated, confidential network connection
between two processes. This includes the time it takes to establish a TCP
connection and execute the [Vanadium authentication protocol] over it.

## Echo

Results: <a href="https://benchmarks.v.io/?q=v.io%2Fx%2Fref%2Fruntime%2Finternal%2Frpc%2Fbenchmark.Benchmark____1B+uploader%3Avlab#">v.io/x/ref/runtime/internal/rpc/benchmark.Benchmark____1B</a>

Sending a 1 byte "echo" request and receiving the response over an established
connection. The Vanadium RPC protocol multiplexes RPCs over a single
established connection.

[benchmarks.v.io]: https://benchmarks.v.io
[Vanadium authentication protocol]: /designdocs/authentication.html
