import signals = require('../webrtc/signals');
import net = require('../net/net.types');

// This file holds the common signalling message type that may be referenced
// from both module environment as well as the core environment.

// TODO(bwiley): Remove hardcoded caesar parameter, replace with something flexible

export interface ChurnSignallingMessage {
  webrtcMessage ?:signals.Message;
  publicEndpoint ?:net.Endpoint;
  caesar ?:number;
}
