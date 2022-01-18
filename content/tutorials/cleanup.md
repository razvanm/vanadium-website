---
title: Internal Tutorial Cleanup
layout: tutorial
weight: 98
toc: false
enumerable: false
---

Delete the tutorial workspace directory.

Might be used in tests, tutorial preparation, etc.

<!-- @deleteTutdirContent @test @completer -->
```
if [ -z "${V_TUT}" ]; then
  echo "V_TUT not defined, nothing to do."
else
  if [ -d "${V_TUT}" ]; then
    /bin/rm -rf $V_TUT
    echo "Removed $V_TUT"
  else
    echo "Not a directory: V_TUT=\"$V_TUT\""
  fi
fi
```
