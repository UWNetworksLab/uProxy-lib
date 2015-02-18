/// <reference path='../third_party/typings/jasmine/jasmine.d.ts' />
/// <reference path="loggingprovider.d.ts" />

describe("Logging Provider", () => {
  var message1 = LoggingProvider.makeMessage('D', 'tag', 'simple string');
  var message3 = LoggingProvider.makeMessage('I', 'test-module', 'second string');
  var message4 = LoggingProvider.makeMessage('W', 'test', 'Bob pinged Alice with id=123456');
  var message5 = LoggingProvider.makeMessage('E', 'test', 'Bob pinged Alice with id=123456');
  var loggingProvider :LoggingProvider.Log;
  var loggingControl :LoggingProvider.LoggingProvider;
  
  beforeEach(() => {
    loggingProvider = new LoggingProvider.Log();
    loggingControl = new LoggingProvider.LoggingProvider();
    loggingControl.setBufferedLogFilter(['*:E']);
    loggingControl.clearLogs();
  });

  it('formats string', () => {
    expect(LoggingProvider.formatMessage(message1))
        .toMatch(/D \[.*\] simple string/);
    expect(LoggingProvider.formatMessage(message3))
        .toMatch(/I \[.*\] second string/);
    expect(LoggingProvider.formatMessage(message4))
        .toMatch(/W \[.*\] Bob pinged Alice with id=123456/);
    expect(LoggingProvider.formatMessage(message5))
        .toMatch(/E \[.*\] Bob pinged Alice with id=123456/);
  });

  it('grab logs', () => {
    // testing default behavior, only log error messages.
    
    loggingProvider.debug('tag1', 'simple string');
    loggingProvider.info('tag1', 'second string');
    loggingProvider.error('tag1', 'third string');
    expect(loggingControl.getLogs().join('\n')).toMatch(
      /E \[.*\] third string/);

    // set to log all messages.
    loggingControl.clearLogs();
    loggingControl.setBufferedLogFilter(['*:D']);
    loggingProvider.debug('tag1', 'simple string');
    loggingProvider.info('tag1', 'second string');
    loggingProvider.error('tag1', 'third string');
    expect(loggingControl.getLogs().join('\n')).toMatch(
      /D \[.*\] simple string\nI \[.*\] second string\nE \[.*\] third string/);

     // set to log messages with level >= info.
    loggingControl.clearLogs();
    loggingControl.setBufferedLogFilter(['*:I']);
    loggingProvider.debug('tag1', 'simple string');
    loggingProvider.info('tag2', 'second string');
    loggingProvider.error('tag3', 'third string');
    expect(loggingControl.getLogs().join('\n')).toMatch(
      /I \[.*\] second string\nE \[.*\] third string/);
  });

  it('Specific filtering level for tag overrides *', () => {
    var logs :string;
    loggingControl.clearLogs();
    loggingControl.setBufferedLogFilter(['*:D', 'tag2:I']);
    loggingProvider.debug('tag1', 'first string');
    loggingProvider.debug('tag2', 'second string');
    loggingProvider.info('tag3', 'third string');

    logs = loggingControl.getLogs().join('\n');

    expect(logs).not.toMatch(/second string/);
    expect(logs).toMatch(/first string/);
    expect(logs).toMatch(/third string/);
  });
});
