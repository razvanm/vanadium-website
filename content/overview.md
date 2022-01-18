---
title: "Vanadium Core"
---

**Vanadium Core** enables building secure distributed applications.

_TODO: explain the relationship with the non-code Vanadium and point to
the old site._

It provides:

<div class="my-7 pl-20 bg-no-repeat [background-size:60px] bg-[url('/images/security.svg')]">
   <p>
      <strong>Complete security model</strong><br>
      Vanadium's security model is based on public-key cryptography, that supports
      fine-grained permissions and delegation. The combination of traditional ACLs
      and "blessings with caveats" supports a broad set of practical requirements.

[Learn more about Security](/concepts/security)
   </p>
</div>
<div class="my-7 pl-20 bg-no-repeat [background-size:60px] bg-[url('/images/codebase.svg')]">
   <p>
      <strong>Symmetrically authenticated and encrypted RPC</strong><br>
      Vanadium Core provides symmetrically authenticated and encrypted RPC, with
      support for bi-directional
      messaging, streaming and proxying, that works on a variety of network
      protocols, including TCP and Bluetooth. The result is a secure communications
      infrastructure that can be used for large-scale datacenter applications as
      well as for smaller-scale enterprise and consumer applications, including
      those needing to cross NAT boundaries.
      All data on the wire is encoded using Vanadium Object Marshalling (VOM),
      which is a performant, self-describing encoding format.

[Learn more about RPC System](/concepts/rpc)
   </p>
</div>
<div class="my-7 pl-20 bg-no-repeat [background-size:60px] bg-[url('/images/discovery.svg')]">
   <p>
      <strong>Distributed naming and discovery</strong><br>
      Vanadium provides a global naming service that offers the convenience of
      urls but allows for federation and multi-level resolution. The
      'programming model' consists of nothing more than invoking methods on
      names, subject to security checks. Vanadium also provides a discovery API
      for advertising and scanning for services over a variety of protocols,
      including BLE and mDNS (Bonjour).

[Learn more about Naming](/concepts/naming)
   </p>
</div>

# Ready to get started?

<p>
   Vanadium is an open source effort, and we welcome your contributions. 5
   Get started now by exploring the tutorials.
</p>

<a href="/tutorials/hello-world"
   class="uppercase tracking-wider border px-[15px] rounded-[4px] h-[36px] inline-flex items-center hover:bg-primary-color/[.04]">
   <span class="block text-[14px]">Start the tutorial</span>
</a>
