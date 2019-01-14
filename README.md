# visotype/elm-dom [![Build Status](https://travis-ci.com/visotype/elm-dom.svg?branch=master)](https://travis-ci.com/visotype/elm-dom)
**Base utilities to help Elm developers build UI libraries**

## Usage Example

Here's a simple UI from the
[Official Elm Guide](https://guide.elm-lang.org/architecture/buttons.html):

```elm
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)

...

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick Decrement ] [ text "-" ]
    , div [] [ text (String.fromInt model) ]
    , button [ onClick Increment ] [ text "+" ]
    ]
```

Here's how you might implement it with **visotype/elm-dom**:

```elm
import Html exposing (Html)
import Dom exposing (..)

...

view : Model -> Html Msg
view model =
  element "div"
    |> appendChildList
      [ element "button"
        |> addAction ("click", Decrement)
        |> appendText "-"

      , element "div"
        |> appendText (String.fromInt model)

      , element "button"
        |> addAction ("click", Increment)
        |> appendText "+"

      ]
    |> render

```

The second version looks more verbose, but you'll notice that the `Html`
package's pattern of nested lists has been replaced with pipeline style code
that reads from left to right and top to bottom. This can come in handy when
generating more complex markup. You'll also notice that HTML properties are
encoded as strings rather than as function names. That makes it simpler to
pass them as arguments to UI constructors.

Let's say you want to wrap this widget in a function and share it across
applications. As a `Dom.Element`, the outermost `div` is capable of being
modified by appending or prepending child elements, adding attributes, swapping
the tag, and so on, which is not possible with rendered Elm `Html`. This pattern
enables UI library developers to bundle sets of minimally-defined reusable parts
that users can then modify to meet their needs.

## Motivation and Design Considerations

I created this package to make it easier for developers in the Elm community to create, share, and collaborate on libraries of reusable functions for building user interfaces. The package does not implement any specific set of UI constructors (beyond the generic `element` constructor) and it is not tied to any external dependencies (like a CSS framework). That means you can use this package to create whatever reusable parts you need, with whatever external frameworks you like to use.

## API Features

- a standard data type for storing information about an individual node in Elm's virtual DOM
- a comprehensive set of functions that allow you to build nodes by updating this information (analogous to methods in the [DOM Element API](https://developer.mozilla.org/en-US/docs/Web/API/Element#Methods), but really just Elm record updates)
- a simple rendering function that outputs Elm `Html`

## Dependencies

Elm platform 0.19 and the `elm/core`, `elm/json`, and `elm/virtual-dom`
packages. Nothing else!

## Tests

Record update and rendering functions have been tested to ensure functional
equivalence with Elm `Html` constructors. To verify, you can install the
[elm-test](https://www.npmjs.com/package/elm-test) NPM package and run
`elm-test` locally from the package's root directory.

## Getting Started

To get started, take a look at any of the examples below, then head over to the
[core module documentation](https://package.elm-lang.org/packages/visotype/elm-dom/latest/Dom).

- [Button.elm](https://github.com/visotype/elm-dom/blob/master/examples/src/Button.elm)
- [Hover.elm](https://github.com/visotype/elm-dom/blob/master/examples/src/Hover.elm)
- [Capture.elm](https://github.com/visotype/elm-dom/blob/master/examples/src/Capture.elm)
- [Parse.elm](https://github.com/visotype/elm-dom/blob/master/examples/src/Parse.elm)

To run these examples in the browser, download [examples/dist](https://github.com/visotype/elm-dom/tree/master/examples/dist) and initialize a local web server.

## Background on the Project

This package is a complete rewrite that includes core parts of several of my earlier
attempts at a UI library for Elm. The most recent iteration included the packages
[elm-semantic-dom](https://github.com/danielnarey/elm-semantic-dom)
and
[elm-modular-ui](https://github.com/danielnarey/elm-modular-ui), which have since
been archived. These previous efforts helped me to identify the core problem I
was trying to solve and to eliminate the parts of my code that were just gratuitous
abstraction or unnecessary duplication of functionality. The following summarizes
what I learned in the process and why I think the current package is a step in the
right direction.

### Interest in UI abstraction among Elm community contributors

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

### Challenges of API design for UI libraries

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

### Toward a resusable design pattern

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

## Extensions
If you build a UI library with this package, let me know, and I will post a link
here.

## Credit
(c) 2018 Daniel C. Narey. Released under BSD 2-Clause "Simplified" License.
