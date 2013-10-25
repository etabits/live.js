

window.Test ?= {}
test = window.Test.testObj = new Test.TestClass 'LiveJS'
#ljs.registerObject test
window.onclick = () ->
	test.greet()

