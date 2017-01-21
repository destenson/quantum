PATH := ./node_modules/.bin:${PATH}

.PHONY : init clean build dist publish

init:
	npm install

clean:
	rm -rf lib/

build:
	./node_modules/coffee-script/bin/coffee -o lib/ -c src/
	# cp ./src/services/config.json ./lib/services/config.json

dist: clean init build

publish: dist
	npm publish
