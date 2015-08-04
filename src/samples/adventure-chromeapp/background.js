chrome.app.runtime.onLaunched.addListener(function() {
  // Prevent the app from suspending.
  // TODO: Use persistent sockets instead:
  //       https://github.com/uProxy/uproxy/issues/1746
  chrome.app.window.create('index.html', {
  	id: "adventure",
    outerBounds: {
      width: 200,
      height: 200,
    }
  });

  var script = document.createElement('script');
  script.src = 'freedom-for-chrome/freedom-for-chrome.js';
  document.head.appendChild(script);
  script.onload = function() {
    console.log('loading freedom!');
    freedom('uproxy-lib/adventure/freedom-module.json', {
      'logger': 'uproxy-lib/loggingprovider/freedom-module.json',
      'debug': 'debug'
    }).then(function(moduleFactory) {
      moduleFactory();
    }, function() {
      console.error('could not load freedomjs module');
    });
  };
});
