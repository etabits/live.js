coffees = $$(find lib/ -name \*.coffee) 'index.coffee'
compile:
	for f in $(coffees); do  coffee -c "$$f"; done