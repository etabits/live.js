// Generated by CoffeeScript 1.6.3
(function() {
  var LiveServer, assetsRegExp, crypto, cs, fs, http, mainFile, prepareCode, scriptFile, sendJavascript, sha1;

  fs = require('fs');

  http = require('http');

  cs = require('coffee-script');

  crypto = require('crypto');

  mainFile = '';

  sha1 = function(str) {
    return crypto.createHash('sha1').update(str).digest('hex');
  };

  scriptFile = __dirname + '/lib/live.js';

  assetsRegExp = /\.(coffee|js)$/;

  LiveServer = (function() {
    var self;

    self = {};

    function LiveServer(opts) {
      var _base;
      this.opts = opts;
      self = this;
      console.log('Instantiated with', this.opts);
      if ((_base = this.opts).port == null) {
        _base.port = 1174;
      }
      this.sockets = [];
      this.hashes = {};
      this.watchRecursively(this.opts.path);
    }

    LiveServer.prototype.watchRecursively = function(path) {
      return fs.stat(path, function(err, stats) {
        var w;
        if (!stats.isDirectory()) {
          return;
        }
        w = fs.watch(path, self.watchHandler);
        w.path = path + '/';
        console.log('Watching', path);
        return fs.readdir(path, function(err, files) {
          var file, _i, _len, _results;
          if (err) {
            return console.log(err);
          }
          _results = [];
          for (_i = 0, _len = files.length; _i < _len; _i++) {
            file = files[_i];
            _results.push(self.watchRecursively(path + '/' + file));
          }
          return _results;
        });
      });
    };

    LiveServer.prototype.watchHandler = function(event, filename) {
      console.log('WATCH', event, filename, new Date());
      return fs.readFile(this.path + filename, function(err, data) {
        var hash;
        if (err) {
          return console.log('File', self.path + filename, 'disappeared or something!');
        }
        hash = sha1(data);
        if (self.hashes[filename] !== hash) {
          self.hashes[filename] = hash;
          return self.triggerUpdateEvent(data, filename);
        }
      });
    };

    LiveServer.prototype.triggerUpdateEvent = function(data, filename) {
      var socket, _i, _len, _ref, _results;
      console.log('updateEvent', filename, new Date());
      if (/\.coffee$/.test(filename)) {
        data = LiveServer.compileCoffeeScript(data);
      }
      _ref = self.sockets;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        socket = _ref[_i];
        _results.push(socket.emit('update', {
          date: new Date(),
          file: filename,
          code: data.toString()
        }));
      }
      return _results;
    };

    LiveServer.prototype.standAlone = function() {
      this.server = http.createServer(this.httpHandler);
      this.doServer(this.server);
      return this.server.listen(this.opts.port);
    };

    LiveServer.prototype.doExpress = function(app, server) {
      this.server = server;
      this.doServer(this.server);
      return app.get('/live.js', function(req, res, next) {
        return self.sendAsset(scriptFile, res);
      });
    };

    LiveServer.prototype.doServer = function(server) {
      if (this.server == null) {
        this.server = server;
      }
      this.io = require('socket.io').listen(this.server);
      return this.io.sockets.on('connection', this.ioHandler);
    };

    LiveServer.prototype.ioHandler = function(socket) {
      return self.sockets.push(socket);
      /*
      		setInterval ->
      			socket.emit 'update', {now: new Date()}
      		, 	1333
      */

    };

    LiveServer.prototype.httpHandler = function(req, res) {
      console.log('Request: ', req.url);
      if ('/live.js' === req.url) {
        return self.sendAsset(scriptFile, res);
      } else if (req.url.match(/\.js$/)) {
        return self.sendAsset(self.opts.path + req.url, res);
      } else {
        res.writeHead(404);
        return res.end('NotFound');
      }
    };

    LiveServer.compileCoffeeScript = function(code) {
      var e;
      try {
        code = cs.compile(code.toString());
        return code;
      } catch (_error) {
        e = _error;
        console.log(e);
        return ';alert("Error Compiling Code");';
      }
    };

    LiveServer.prototype.getAssetContent = function(path, cb) {
      return fs.readFile(path, function(err, code) {
        if (err) {
          return fs.readFile(path.replace(/\.js$/, '.coffee'), function(err, code) {
            console.log(err);
            code = LiveServer.compileCoffeeScript(code);
            return cb(code);
          });
        } else {
          return cb(code.toString());
        }
      });
    };

    LiveServer.prototype.sendAsset = function(path, res) {
      return this.getAssetContent(path, function(code) {
        return sendJavascript(code, res);
      });
    };

    return LiveServer;

  })();

  sendJavascript = function(code, res) {
    res.writeHead(200, {
      'Content-Type': 'text/javascript'
    });
    return res.end(code);
  };

  prepareCode = function(cb) {
    return fs.readFile(scriptFile, function(err, data) {
      var code;
      code = cs.compile(data.toString());
      return cb(code);
    });
  };

  module.exports.LiveServer = LiveServer;

}).call(this);
