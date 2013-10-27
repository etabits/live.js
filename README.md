live.js
=======

Better Web Development: Edit your javascript sources without refreshing your webpage.

## Example
Execute
```sh
make vanilla-test
```
It will open an example html file in a browser window, a .coffee script file in an editor, and finally the live script that will watch for changes and push them to the browser.

* On the browser window, click the button, and it will execute the function call as specified by current code in the file.
* Now edit the file, and save.
* Changes are now pushed to the browser, click the button and check new code!


## Usage
1. Add a this script tag to your html file:

```html
<script id="live-js" data-settings='{"namespaces":"Test","pattern":"/js/.+\\.js$"}'
  src="http://127.0.0.1:1174/live.js"></script>
```

before the closing `</body>`

2. run the live binary :

```sh
./bin/live ./path/to/html/root
```
