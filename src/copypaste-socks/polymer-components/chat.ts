/// <reference path='../../../../third_party/polymer/polymer.d.ts' />

import copypaste_api = require('../copypaste-api');
declare module browserified_exports {
  var copypaste :copypaste_api.CopypasteApi;
}
import copypaste = browserified_exports.copypaste;

import I18nUtil = require('../i18n-util.types');
declare var i18nUtil :I18nUtil;

Polymer({
  model: copypaste.model,
  sendChatMessage : function() {
    console.log("sendChatMessage: " + copypaste.model.inboundChatText);
    copypaste.sendChatMessage(copypaste.model.inboundChatText);
    copypaste.model.inboundChatText = '';
  },
  ready: function() {
    i18nUtil.translateStrings(this);
  }
});
