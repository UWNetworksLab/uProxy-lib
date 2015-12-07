[![Build Status](https://travis-ci.org/uProxy/uproxy-lib.svg?branch=master)](https://travis-ci.org/uProxy/uproxy-lib)
[![Build Status](https://api.shippable.com/projects/54c823bf5ab6cc135289fbd8/badge?branchName=dev)](https://app.shippable.com/projects/54c823bf5ab6cc135289fbd8/builds/latest)
[![devDependency Status](https://david-dm.org/uProxy/uproxy-lib/dev-status.svg)](https://david-dm.org/uProxy/uproxy-lib#info=devDependencies)

Obfuscating, WebRTC-driven SOCKS proxy and other utilities for [uProxy](https://www.uproxy.org/).

## Setup

### Prerequisites

 * NPM, which may be installed as part of [Node.js](http://nodejs.org/).
 * [Grunt](http://gruntjs.com/) which may, once NPM has been installed, be installed with the command `npm install -g grunt-cli`

### Building

First, to install required NPMs and configure the `build/` directory for TypeScript compilation, execute:
```bash
./setup.sh install
```

On Windows, replace `./setup.sh` with `.\setup.cmd`.

Then, to compile the TypeScript code and build the demo apps, execute:
```bash
grunt samples
```

Now, you should be able to run the demo apps.

Having problems? To clean up from a partial, broken, or extremely out-dated build, try executing this command before repeating the above steps:
```bash
./setup.sh clean
```

## Developing

Sublime Text 3 provides a good development experience:

 * Install [Sublime Text 3](http://www.sublimetext.com/3).
 * Install [Package Control](https://packagecontrol.io/).
 * Install the TypeScript package [home page](https://github.com/Microsoft/TypeScript-Sublime-Plugin).

Now, TypeScript files will have syntax highlighting and include support for "jump to definition" and refactoring (renaming).

Several compile errors will remain, namely imports from `../../../third_party`. To workaround, Unix (and OSX) users can create a symlink:

 * `cd` to the directory containing the repo
 * `ln -s uproxy-lib/build/third_party ../third_party`

Re-compile, with F7 (and perhaps restart Sublime, just to be sure) to resolve these errors.

## Demo apps

After building, the apps can be found at `build/dev/uproxy-lib/samples/`. They
are a mix of web apps and browser extensions (Chrome and Firefox).

To run web apps:
 * start a webserver, e.g. `python -m SimpleHTTPServer`
 * open the relevant HTML file in your browser, e.g. http://localhost:8000/build/dev/uproxy-lib/samples/simple-freedom-chat/main.html.

To run Chrome apps:

 - open `chrome://extensions`, enable check Developer Mode, and load the unpacked extension from the relevant directory, e.g. `build/dev/uproxy-lib/samples/simple-socks-chromeapp/`.

To run Firefox add-ons:

- install [jpm](https://developer.mozilla.org/en-US/Add-ons/SDK/Tools/jpm) via NPM, e.g. `npm install jpm -g`, `cd` to the relevant directory, e.g. `build/dev/uproxy-lib/samples/simple-socks-firefoxapp/`, and execute ``jpm run -b `which firefox` ``.

To run Node.js apps:

 - Directly run `node` with the entry point, e.g. `node build/dev/uproxy-lib/samples/zork-node/index.js`
 - Note: Until freedom-for-node supports core.rtcpeerconnection, this sample will not work

### simple-freedom-chat

WebRTC-powered chat client, with both peers on the same page.

This is the simplest possible demo and test of `src/peerconnection`.

### copypaste-freedom-chat

Simplest possible, distributed, `src/peerconnection` demo in which text boxes
act as the signalling channel between two peers. Messages can be exchanged by
email, IM, shared doc, etc.

### echo-server

Starts a TCP echo server on port 9998. Run `telnet 127.0.0.1 9998` and then
type some stuff to verify that echo server echoes what you send it.

Press ctrl-D to have the echo server terminate the connection or press
`ctrl-]` then type `quit` to exit telnet.

### Simple SOCKS

Simplest possible, single-page, demo of the SOCKS proxy (`socks-to-rtc` and
`rtc-to-net` directories).

This command may be used to test the proxy:

```bash
curl -x socks5h://localhost:9999 www.example.com
```

(the `-h` indicates that DNS requests are made through the proxy too, i.e. not resolved locally)

Alternatively, use an extension like [SwitchyProxySharp](https://chrome.google.com/webstore/detail/proxy-switchysharp/dpplabbmogkhghncfbfdeeokoefdjegm?hl=en)
to set Chrome's proxy settings and then just browse stuff.

To see debugging output, open the background page.

### Zork

Distributed SOCKS proxy with a telnet-based signalling channel.

Intended for use with [our Docker-based integration testing](https://github.com/uProxy/uproxy-docker).

If you're curious, try `telnet localhost 9000` or running `bin/connect-pair.py`.

### uProbe

Guess-timates your NAT type.

### copypaste SOCKS

Distributed SOCKS proxy demo. This is essentially uProxy without any
social network integration.

### simple-churn-chat

As simple-fredom-chat, except WebRTC traffic between the two peers is obfuscated.

Wireshark may be used to verify that the traffic is obfuscated; the endpoints
in use - along with a lot of debugging information - may be determined by
examining the Javascript console.

### copypaste-freedom-chat

As copypaste-fredom-chat, except WebRTC traffic between the two peers is obfuscated.

### Simple TURN

Simplest possible demo of the TURN server.

The TURN "frontend" interacts directly with TURN clients, the "backend" manages
relay sockets:

```
                                                    +-------------+
                                                    |             |
                                                    |          ++ +------->
                    +-------------+                 |          ++ |
                    |             |                 |             |
TURN client +-----> | oo          | <-------------> |          ++ +------->
                    | oo          |      webrtc     |          ++ |
                    |             |                 |             |
                    +---+---------+                 |          ++ +------->
                    TURN frontend                   |          ++ |
                                                    |             |
                                                    +---+---------+
                                                    TURN backend

                      oo                              ++
                      oo server socket                ++ relay socket
```

The server may be used with standard TURN clients, e.g. the command-line
tools from the `rfc5766-turn-server` suite:

* Install the [rfc5766-turn-server](https://code.google.com/p/rfc5766-turn-server) client utilities (`apt-get install rfc5766-turn-server` on Debian-like systems)
* Open a terminal and execute `turnutils_peer`. This starts a UDP echo server on ports 3480 and 3481.
* Open another terminal and execute `turnutils_uclient -s -u test -w test -e 127.0.0.1 127.0.0.1 -p 9997`

You should see a flurry of activity in the Chrome debugging console. On the
command line, you will soon see a report. The output is not very user-friendly
but the important parts are `tot_send_msgs` and `tot_send_bytes`. With the TURN
server, echo server, and TURN client all running locally, you should not see
any dropped packets. For more options, e.g. to open more channels or send
larger datagrams, see the
[turnutils_uclient documentation](https://code.google.com/p/rfc5766-turn-server/wiki/turnutils_uclient).

## Obfuscation

WebRTC data channels are secured with
[DTLS](http://en.wikipedia.org/wiki/Datagram_Transport_Layer_Security).

An observer of the network traffic passing between two connected hosts can
see that DTLS is in use; from this, they may infer that data channels are in
use. We wish to make it difficult for an observer to detect the use of uProxy.

The SOCKS server configures WebRTC to pass its network traffic through a local
network port which transforms the data prior to sending it over the internet; a
port on the remote host is similarly configured to restore the data to its
original form prior to delivering it to the remote WebRTC peer.

We call this system "churn", and its code can be found in `src/churn/`.

## Benchmarking

 * Build everything and start Simple SOCKS (see above).
 * Do these once:
   * `bin/make-data.sh`
   * `npm install -g wup`
 * Run wup: `(cd data ; wup) &`
 * Then, run the benchmark with `npm run benchmark`.
