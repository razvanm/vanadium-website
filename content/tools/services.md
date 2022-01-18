---
title: Vanadium Cloud Services
toc: true
---

While it's possible to run all Vanadium infrastructure services on your own we host several of them to ease development overhead. The following services are available to use and are often the default values for most configurations. All services listed here are covered by the the [terms of service].

# Mount table

The [Mount table] is a service that allows other Vanadium applications to discover and address one another. To be discovered an application will mount itself at a "name" and other applications (clients) can then address the service.

See also: [Naming Concepts], [`mounttable` Go documentation]

# Identity service

The Identity Service is an HTTP server that uses OAuth to create blessings. It allows users to "login" to a service and affords them the ability to generate and manage access credentials.
Google runs such a service at https://dev.v.io/auth.

See also: [Security Concepts], [identityd Go documentation], [Identity service FAQ]

# Proxy service

The Proxy Service listens for connections from Vanadium services (typically behind NATs) and proxies these services to the outside world.

See also: [proxy Go documentation]

[proxy Go documentation]: https://godoc.org/v.io/x/ref/services/proxy
[`mounttable` Go documentation]: https://godoc.org/v.io/x/ref/services/mounttable
[Mount table]: /2016/glossary.html#mount-table
[Naming Concepts]: /2016/concepts/naming.html
[Security Concepts]: /2016/concepts/security.html
[identityd Go documentation]: https://godoc.org/v.io/x/ref/services/identity/identityd
[terms of service]: /2016/tos.html
[Identity service FAQ]: /2016/tools/identity-service-faq.html
