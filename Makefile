coffees = $$(find lib/ -name \*.coffee) 'index.coffee'

vanilla-test: compile
	./bin/live ./examples/vanilla/

compile:
	for f in $(coffees); do  coffee -c "$$f"; done