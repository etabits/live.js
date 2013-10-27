class TestClass
	constructor: (@name) ->
		#console.log @name

	greet: (name) ->
		if 1 #change this line back and forth between `0' and `1',
			 #and go click the browser button without refreshing
			name ?= 'Hasan' # Or edit this string putting your name here!
		else
			name ?= 'Visitor'
		window.alert "Hello #{name}, I am #{@name}!"



window.Test ?= {}
window.Test.TestClass = TestClass





