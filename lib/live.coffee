log = console.log

class LiveJS
	self = {}
	constructor: (@opts) ->
		self = this
		@opts.pattern = new RegExp @opts.pattern
		@opts.serverBase ?= serverBase
		@opts.namespaces = @opts.namespaces.split(',') if 'string' == typeof @opts.namespaces

		log 'Using settings: ', @opts
		@scripts = {}
		@objects = []
		for script in document.getElementsByTagName 'script'
			continue if !@opts.pattern.test(script.src)
			#console.log(script)
			@scripts[script.src] = script;
		log 'Collected Scripts:', @scripts
		@socket = io.connect @opts.serverBase
		@socket.on 'update', @updateHandler



	updateHandler: (data) ->
		console.log 'UPDATE', data.date, data.file
		#console.log data.code
		eval data.code
		#console.log 'OPTS', self.opts
		for ns in self.opts.namespaces
			console.log 'Patching NS', ns
			for objName, obj of window[ns]
				continue if 'object' != typeof obj
				console.log 'Patching Object', ns, '.', objName
				className = obj.__proto__.constructor.name
				newPrototype = window[ns][className].prototype
				#console.log className, newPrototype
				for propName, prop of newPrototype
					continue if 'function' != typeof prop
					#console.log propName, prop+'', obj[propName]+''
					obj[propName] = prop

	registerObject: (obj) ->
		@objects.push obj

	reload: () ->
		for src, script of @scripts
			newScript = document.createElement 'script'
			newScript.src = src
			document.body.appendChild newScript
			@scripts[src] = newScript
			#script.src = src+'?' + Math.random()
		@patch()
		return null
	patch: () ->
		for obj in @objects
			className = obj.__proto__.constructor.name
			for name, func of window[className].prototype #namespacing?!
				#console.log name, func, typeof func
				continue if 'function' != typeof func
				obj[name] = func

		#for obj in

window.LiveJS = LiveJS


elem = document.getElementById 'live-js'
serverBase = ''
onload = () ->
	#console.log typeof LiveJS
	#console.log elem.attributes['data-settings'].value
	settings = JSON.parse elem.attributes['data-settings'].value
	#console.log settings
	ljs = new LiveJS settings

#console.log 'HHH'
if elem

	serverBase = elem.src.replace('/live.js', '')
	socketioSrc = serverBase + '/socket.io/socket.io.js'
	sioScript = document.createElement 'script'
	sioScript.src = socketioSrc
	document.body.appendChild sioScript

	if window.addEventListener
		window.addEventListener 'load', onload, false
	