# uProxy Tools

This directory contains some tools for uProxy. In particular:

 * `taskmanager.js` is a small JS library for managing tasks and avoid having duplicate ones (but preserving order in the sense of still doing the first task the first time it is needed).

Note: because the `uproxy-lib` Gruntfile uses taskmanager, we store it in git both the uncompiled (in `src/taskmanager`) as well as compiled (in `tools/`). The grunt rule `tools` will rebuild the code in the tools directory from the src.
