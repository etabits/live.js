fs = require 'fs'
http = require 'http'
cs = require 'coffee-script'
crypto = require 'crypto'

mainFile = ''

#var md5 = function(str) { return  require('crypto').createHash('md5').update(str).digest("hex"); }
sha1 = (str) ->
	crypto.createHash('sha1').update(str).digest('hex')


scriptFile = __dirname + '/lib/live.js'

assetsRegExp = /\.(coffee|js)$/

class LiveServer
	self = {}
	constructor: (@opts) ->
		self = this
		console.log 'Instantiated with', @opts
		@opts.port  ?= 1174
		#@opts.match ?= /\/js\/.+\.js$/
		@sockets = []
		@hashes = {}

		@watchRecursively(@opts.path)

	watchRecursively: (path) ->

		fs.stat path, (err, stats) ->
			if !stats.isDirectory()
				#console.log path, assetsRegExp.match
				return
			w = fs.watch path , self.watchHandler		
			w.path = path + '/'
			console.log 'Watching', path
			#watchRecursively path
			
			fs.readdir path, (err, files) ->
				if err
					return console.log err
				for file in files
					self.watchRecursively path + '/' + file

	watchHandler: (event, filename) ->
		console.log 'WATCH', event, filename, new Date()
		fs.readFile this.path + filename, (err, data) ->
			hash = sha1 data
			if self.hashes[filename] != hash
				self.hashes[filename] = hash
				self.triggerUpdateEvent data, filename



	triggerUpdateEvent: (data, filename) ->
		if /\.coffee$/.test(filename)
			data = LiveServer.compileCoffeeScript data
		for socket in self.sockets
			socket.emit 'update', {
					date: new Date(),
					file: filename,
					code: data.toString()
				}


	standAlone: () ->
		@server = http.createServer @httpHandler

		@doServer @server
		@server.listen @opts.port
		#console.log @server
		#console.log @io

	doExpress: (app, @server) ->
		@doServer @server
		app.get '/live.js', (req, res, next) ->
			#console.log 'AAAAA'
			self.sendAsset scriptFile, res

	doServer: (server) ->
		@server ?= server
		#console.log @server
		@io = require('socket.io').listen @server
		@io.sockets.on 'connection', @ioHandler
		#console.log server

	ioHandler: (socket) ->
		self.sockets.push socket
		#console.log '>>>', socket
		#console.log(socket)
		###
		setInterval ->
			socket.emit 'update', {now: new Date()}
		, 	1333
		###
	httpHandler: (req, res) ->
		console.log 'Request: ', req.url
		if '/live.js' == req.url
			self.sendAsset scriptFile, res
#			prepareCode (code) ->
#				sendJavascript code, res
		else if req.url.match /\.js$/
			#console.log self.opts.path
			self.sendAsset self.opts.path + req.url, res #FIXME SECURITY HOLE!!!
			#res.end('')
		else
			res.writeHead(404)
			res.end('NotFound')

	@compileCoffeeScript: (code) ->
		try
			code = cs.compile code.toString()
			return code
		catch e
			console.log e
			return ';alert("Error Compiling Code");'
		


	getAssetContent: (path, cb) ->
		fs.readFile path, (err, code) ->
			#console.log err
			if err #coffee-script
				fs.readFile path.replace(/\.js$/, '.coffee'), (err, code) ->
					console.log err
					code = LiveServer.compileCoffeeScript code
					cb code
			else
				cb code.toString()

	sendAsset: (path, res) ->
		@getAssetContent path, (code) ->
			sendJavascript code, res



sendJavascript = (code, res) ->
	res.writeHead 200, { 'Content-Type': 'text/javascript' }

	res.end(code)


prepareCode = (cb) ->
	fs.readFile scriptFile, (err, data) ->
		code = cs.compile data.toString()
		#console.log code
		cb code



module.exports.LiveServer = LiveServer