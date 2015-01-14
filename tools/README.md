# uProxy Tools

This directory contains some tools for uProxy. In particular:

 * `taskmanager.js` is a small JS library for managing tasks and avoid having duplicate ones (but preserving order in the sense of still doing the first task the first time it is needed).
 * `common-grunt-rules.js` is a small JS library for common grunt rules.

Note: because the `uproxy-lib` Gruntfile uses these tools, we store in git both the uncompiled (in `src/taskmanager`) as well as the compiled code (in `tools/`). These JS utilities created by the grunt rule `tools`.
