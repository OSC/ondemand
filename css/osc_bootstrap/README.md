## Compiling the Namespaced bootstrap

 This folder contains sources for compiling a namespaced bootstrap file.

 The `.less` file imports and prefixes the `bootstrap.css` file.

 I built this file using [WinLess](http://winless.org/), but you should be able to generate the file on the command line with:

 ```
 $ lessc --clean-css bootstrap_namespaced.less bootstrap.min.css
 ```
