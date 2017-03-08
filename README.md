# ceri-dev-server

ceri-dev-server is a small development server for building `custom elements` with ceriJS. 
It takes different environments and makes them available in your browser.

Additionally it can create a static version for ghpages or perform unit tests


### Install

```sh
npm install --save-dev ceri-dev-server
```

### Usage - cli

```
Usage: ceri-dev-server [options]

  Options:

    -h, --help               output usage information
    -V, --version            output the version number
    -p, --port <number>      port to use (default: 8080)
    -f, --folder <path>      root path (default: dev)
    -s, --static <path>      exports a static version (for ghpages)
    -e, --extensions <list>  extensions to match (default: js,coffee)
    -t, --test               runs karma on the folder
    -w, --watch              only with --test, runs karma in watch mode
    --browsers <list>        only with --test, sets browsers

```

### Setting up an environment

By default `ceri-dev-server` will look in the `dev` folder for files.
Just create a `someName.js|.coffee` file there. Require your `custom element` from there normally.  
The server will be accessible under `http://localhost:8080/` by default.

##### Example of project layout
```
./dev/index.js // Contains an environment to interact with your component.
./src/comp.js // your component.
./comp.js // your component compiled down to ES5.
```
Also see [ceri-boilerplate](https://github.com/cerijs/ceri-boilerplate).

### Using static option to create a demo for github pages

in conjuction with [gh-pages](https://github.com/tschaub/gh-pages), creating a demo is as simple as this:
```sh
ceri-dev-server --static static/ && gh-pages -d static
```
just make sure you include the static folder in your .gitignore

### Setting up webpack

This is the default loaders list:
```coffee
module:
  rules: [
    { test: /\.html$/, use: "html-loader"}
    { test: /\.coffee$/, use: "coffee-loader"}
    { test: /\.css$/, use: ["style-loader","css-loader"] }
    {
      test: /\.(js|coffee)$/
      use: "ceri-loader"
      enforce: "post"
      exclude: /node_modules/
    }
  ]
```
If you need you own, put a webpack.config.js /.coffee/.json in the project folder, it will get merged for the dev server as well as for karma.

### Additional info
 - You can create a npm script in your `package.json`, `"scripts": {"dev": "ceri-dev-server", "test": "ceri-dev-server --test"}`. Then you can call it by `npm run dev` or `npm test`

## License
Copyright (c) 2017 Paul Pflugradt
Licensed under the MIT license.
