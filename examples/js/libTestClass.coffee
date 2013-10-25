class TestClass
	constructor: (@name) ->
		console.log @name

	greet: (name) ->
		if 1
			name ?= 'Hasan'
		else
			name ?= 'Visitor'
		window.alert "Hello #{name}, I am #{@name}!"



window.Test ?= {}
window.Test.TestClass = TestClass





