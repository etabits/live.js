coffees = $$(find lib/ -name \*.coffee) 'index.coffee'

compile:
	for f in $(coffees); do  coffee -c "$$f"; done

prepare:
	npm install

vanilla-test: prepare
	sh -c 'sleep 1; xdg-open examples/vanilla/js/libTestClass.coffee; xdg-open examples/vanilla/test.html;' &
	./bin/live ./examples/vanilla/

expressjs-test: prepare
	sh -c 'sleep 2; xdg-open examples/express/public/js/libTestClass.coffee; xdg-open http://localhost:3000/' &
	cd examples/express/ && node app.js