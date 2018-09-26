# visotype/elm-dom
## Base utilities to help Elm developers build UI libraries

If you are using Elm, you probably know all of the reasons why Elm is great. If
you've been using Elm for a while, you probably also have some ideas about
things that could be done better. One idea that has been explored in a number
of community packages is how take advantage of the capabilities of the Elm
language to write better view code for Elm sites and apps. "Better" can mean
different things to different people, but one goal shared by different community
UI packages has been to rely less on literal templating of HTML markup by
introducing some sort of abstraction at the element and/or component levels
(*I'll avoid the word "component" from here on to avoid any possible confusion
with React-style stateful components*). While there can be a tradeoff in API
design between explicit specification and abstraction, good abstractions can
help to facilitate rapid prototyping, code sharing, and improved maintainability
as sites and apps scale.

UI abstraction has not been a focus of core Elm language development since the
[early days](https://www.infoq.com/presentations/Elm)
(pre-2014) when the Elm core library included a set of
[graphics modules](https://package.elm-lang.org/packages/elm-lang/core/3.0.0/Graphics-Input).
As part of the effort to
[take Elm mainstream](http://www.elmbark.com/2016/03/16/mainstream-elm-user-focused-design),
these modules were dropped and replaced with the `Html` and `Svg` packages,
backed by Elm's [VirtualDom](https://elm-lang.org/blog/blazing-fast-html).
Now that the Elm platform is stabilizing and can be used more confidently in
[production](https://elm-lang.org/blog/small-assets-without-the-headache),
there is an opportunity for Elm community contributors to create UI libraries
that address specific needs, relying on `VirtualDom` for internals.

In designing an API for a UI library, a lot of decisions need to be made about
data structures, naming schemes, and functional patterns (like the order of
arguments, whether arguments are given as separate values, tuples, or records,
and so on). When package developers make different decisions about these things,
it becomes more difficult to use different UI libraries together, either
because of a basic incompatibility of patterns, or just because each has its own
learning curve and trying to integrate something new will increase development
time for the user. This leads to a trend where each UI library is its own
island, resulting in duplication of effort and lack of movement toward standard
implementations of things that a lot of users in the community would like to
have.

Surveying this situation, I wanted to make it easier for developers in the Elm
community to create, share, and collaborate on libraries of reusable
functions for building user interfaces. Toward this end, the `visotype/elm-dom`
package offers a basic set of utilities for UI development in Elm, including a
data type for storing information about an individual node, a comprehensive set
of functions that allow you to build nodes by updating this information, and a
simple rendering function that outputs Elm `Html`. The package does not
implement any specific set of UI constructors (beyond the generic `element`
constructor) and it is not tied to any external dependencies (like a CSS
framework). That means you can use this package to create whatever reusable
parts you need, with whatever external frameworks you like to use. The benefit
you get is a standard type that can be used across all of your custom UI
functions and a thoroughly tested set of utility functions for building,
modifying, and rendering nodes.

To get started, take a look at any of the examples below, then head over to the
[core module documentation](https://package.elm-lang.org/packages/visotype/elm-dom/latest/Dom).

### Examples
- [Button.elm](https://github.com/visotype/elm-dom/blob/master/examples/src/Button.elm)
- [Hover.elm](https://github.com/visotype/elm-dom/blob/master/examples/src/Hover.elm)
- [Capture.elm](https://github.com/visotype/elm-dom/blob/master/examples/src/Capture.elm)
- [Parse.elm](https://github.com/visotype/elm-dom/blob/master/examples/src/Parse.elm)

To run examples locally, initialize a web server at [examples/dist](https://github.com/visotype/elm-dom/tree/master/examples/dist).

### Tests
Record update and rendering functions have been tested to ensure functional
equivalence with Elm `Html` constructors. To verify, you can install the
[elm-test](https://www.npmjs.com/package/elm-test) NPM package and run
`elm-test` locally from the package's root directory.

### Dependencies
Elm platform 0.19 and the `elm/core`, `elm/json`, and `elm/virtual-dom`
packages. Nothing else!

### Extensions
If you build a UI library with this package, let me know, and I will post a link
here.

### Credit
(c) 2018 Daniel C. Narey. Released under BSD 2-Clause "Simplified" License.
