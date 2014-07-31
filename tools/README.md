# uProxy Tools

This directory contains some tools for uProxy. In particular:

 * `common-grunt-rules.*` is both the typescript and JS for common grunt rules for a uproxy project with our common directory layout (all built stuff goes in `build/`, typescript sym-linked in `build/typescript-src`, etc).

 * `taskmanager.js` (original source code is in `src/taskmanager/`) is a small JS library for managing tasks and avoid having duplicate ones (but preverving order in the sense of still doing the first task the first time it is needed).

Note: because the `uproxy-lib` Gruntfile uses these tools, we store in git both the uncompiled as well as the compiled code.
