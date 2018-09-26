module Dom exposing
  ( Element
  , element
  , render
  , setId
  , addClass
  , addStyle
  , addAttribute
  , addAction
  , addInputHandler
  , addChangeHandler
  , addToggleHandler
  , appendText
  , prependText
  , appendChild
  , prependChild
  , appendNode
  , prependNode
  , addClassList
  , addStyleList
  , addAttributeList
  , appendChildList
  , prependChildList
  , appendNodeList
  , prependNodeList
  , setChildListWithKeys
  , setNodeListWithKeys
  , addClassConditional
  , addStyleConditional
  , addAttributeConditional
  , addClassListConditional
  , addStyleListConditional
  , addAttributeListConditional
  , addActionConditional
  , appendTextConditional
  , prependTextConditional
  , appendChildConditional
  , appendChildListConditional
  , prependChildConditional
  , prependChildListConditional
  , removeClass
  , removeStyle
  , removeListener
  , replaceClassList
  , replaceStyleList
  , replaceAttributeList
  , replaceText
  , replaceTextConditional
  , replaceChildList
  , replaceChildListConditional
  , replaceNodeList
  , setTag
  , setNamespace
  , addInputHandlerWithParser
  , addChangeHandlerWithParser
  , addListener
  , addListenerConditional
  , addActionStopPropagation
  , addListenerStopPropagation
  , addActionPreventDefault
  , addListenerPreventDefault
  , addActionStopAndPrevent
  , addListenerStopAndPrevent
  , getData
  )


{-|

# Element
@docs Element

# Create and Render
@docs element
@docs render

# Build

## Using a single argument...

### to set the id attribute
@docs setId

### to add a class, style, or other attribute
@docs addClass
@docs addStyle
@docs addAttribute

### to add an event listener
@docs addAction
@docs addInputHandler
@docs addChangeHandler
@docs addToggleHandler

### to append or prepend internal text
@docs appendText
@docs prependText

### to append or prepend a child element
@docs appendChild
@docs prependChild

**you can also supply an `Html` node**
@docs appendNode
@docs prependNode

## Using a list argument...

### to add a list of classes, styles, or other attributes
@docs addClassList
@docs addStyleList
@docs addAttributeList

### to append or prepend a list of child elements
@docs appendChildList
@docs prependChildList

**you can also supply a list of `Html` nodes**
@docs appendNodeList
@docs prependNodeList

## Using a conditional parameter...

### when adding a class, style, or other attribute
@docs addClassConditional
@docs addStyleConditional
@docs addAttributeConditional

### when adding a list of classes, styles, or other attributes
@docs addClassListConditional
@docs addStyleListConditional
@docs addAttributeListConditional

### when adding an event listener for an action
@docs addActionConditional

### when appending or prepending internal text
@docs appendTextConditional
@docs prependTextConditional

### when appending or prepending child elements
@docs appendChildConditional
@docs appendChildListConditional
@docs prependChildConditional
@docs prependChildListConditional

# Modify

## Removing all instances of a single name or key
@docs removeClass
@docs removeStyle
@docs removeListener

## Replacing the existing list of classes, styles, or other attributes
@docs replaceClassList
@docs replaceStyleList
@docs replaceAttributeList

## Replacing the existing text
@docs replaceText
@docs replaceTextConditional

## Replacing the existing descendant tree
@docs replaceChildList
@docs replaceChildListConditional
@docs replaceNodeList

# Advanced Usage

## Setting an element's HTML/XML tag and namespace
@docs setTag
@docs setNamespace

## Using the `Html.Keyed` optimization
@docs setChildListWithKeys
@docs setNodeListWithKeys

## Customizing event handling...

### by transforming input values
@docs addInputHandlerWithParser
@docs addChangeHandlerWithParser

### by using a custom decoder
@docs addListener
@docs addListenerConditional

### by using custom handler options

**stop propagation**
@docs addActionStopPropagation
@docs addListenerStopPropagation

**prevent default**
@docs addActionPreventDefault
@docs addListenerPreventDefault

**both**
@docs addActionStopAndPrevent
@docs addListenerStopAndPrevent

# Debug
@docs getData

-}


import VirtualDom
import Json.Decode exposing (Decoder)

import Dom.Internal as Internal


{-| `Dom.Element` is an [opaque type] that stores an internal record,
[defined here]. The internal record contains all of the data needed to construct an
Elm `Html` node. By using a record to temporarily store data about a node, we
can partially construct that node with some data, but delay building it until
all of the data has been assembled.

A new `Element` record is created when you call the [element] function. The
record is then rendered to `Html` when it is added as a child element to another
`Element` record, or when it is passed as an argument to the [render]
function.

Because rendering is built into the functional development pattern of
this package, it is often only necessary to call the `render` function once, on
the root node of your DOM tree. (One notable exception is when you want to use
the [Html.Lazy] optimization; see [here] for a very simple example of how you
would implement that with this package).

[opaque type]: https://medium.com/@ghivert/designing-api-in-elm-opaque-types-ce9d5f113033
[defined here]: https://package.elm-lang.org/packages/visotype/elm-dom/latest/Dom-Internal#Data
[element]: https://package.elm-lang.org/packages/visotype/elm-dom/latest/Dom#element
[render]: https://package.elm-lang.org/packages/visotype/elm-dom/latest/Dom#render
[Html.Lazy]: https://package.elm-lang.org/packages/elm/html/latest/Html-Lazy
[here]: https://github.com/visotype/elm-dom/blob/master/examples/src/Hover.elm

-}
type alias Element msg =
  Internal.Element msg


---- CONSTRUCTOR ----

{-| Constructor for `Element` records. The string argument provides the HTML
tag.
-}
element : String -> Element msg
element tag =
  { tag = tag
  , id = ""
  , classes = []
  , styles = []
  , listeners = []
  , attributes = []
  , text = ""
  , children = []
  , namespace = ""
  , keys = []
  }
    |> Internal.Element


---- RENDERING ----

{-| Convert an `Element` record to Elm `Html`. This function only needs to be
called once, on the root node of your DOM tree.
-}
render : Element msg -> VirtualDom.Node msg
render =
  Internal.render


---- MODIFIERS ----


-- ID

{-| Sets or resets the id attribute
-}
setId : String -> Element msg -> Element msg
setId s =
  Internal.modify (\n -> { n | id = s })


-- CLASS

{-| Adds a class name to the current list
-}
addClass : String -> Element msg -> Element msg
addClass s =
  Internal.modify (\n -> { n | classes = List.append n.classes [s] })


{-| Adds a class name to the current list when the condition is `True`
-}
addClassConditional : String -> Bool -> Element msg -> Element msg
addClassConditional s test =
  case test of
    True -> addClass s
    False -> (\x -> x)


{-| Adds a list of class names to the current list
-}
addClassList : List String -> Element msg -> Element msg
addClassList ls =
  Internal.modify (\n -> { n | classes = List.append n.classes ls })


{-| Adds a list of class names to the current list when the condition is `True`
-}
addClassListConditional : List String -> Bool -> Element msg -> Element msg
addClassListConditional ls test =
  case test of
    True -> addClassList ls
    False -> (\x -> x)


{-| Removes all instances of a class name from the current list
-}
removeClass : String -> Element msg -> Element msg
removeClass s =
  Internal.modify (\n -> { n | classes = n.classes |> List.filter ((/=) s) })


{-| Replaces the current list of class names with a new list
-}
replaceClassList : List String -> Element msg -> Element msg
replaceClassList ls =
  Internal.modify (\n -> { n | classes = ls })


-- STYLE

{-| Adds a style key/value pair to the current list
-}
addStyle : (String, String) -> Element msg -> Element msg
addStyle kv =
  Internal.modify (\n -> { n | styles = List.append n.styles [kv] })


{-| Adds a style key/value pair to the current list when the condition is `True`
-}
addStyleConditional : (String, String) -> Bool -> Element msg -> Element msg
addStyleConditional kv test =
  case test of
    True -> addStyle kv
    False -> (\x -> x)


{-| Adds a list of style key/value pairs to the current list
-}
addStyleList : List (String, String) -> Element msg -> Element msg
addStyleList lkv =
  Internal.modify (\n -> { n | styles = List.append n.styles lkv })


{-| Adds a list of style key/value pairs to the current list when the condition
is `True`
-}
addStyleListConditional : List (String, String) -> Bool -> Element msg -> Element msg
addStyleListConditional lkv test =
  case test of
    True -> addStyleList lkv
    False -> (\x -> x)


{-| Removes all instances of a style key from the current list
-}
removeStyle : String -> Element msg -> Element msg
removeStyle s =
  let
    isNotKey name (k, v) =
      k /= name

  in
    Internal.modify (\n -> { n | styles = n.styles |> List.filter (isNotKey s) })


{-| Replace the current list of style key/value pairs with a new list
-}
replaceStyleList : List (String, String) -> Element msg -> Element msg
replaceStyleList lkv =
  Internal.modify (\n -> { n | styles = lkv })


-- OTHER ATTRIBUTES

{-| Adds an attribute to the current list

Note: For [complicated reasons], there is more than one `VirtualDom`
primitive for assigning attributes to DOM elements. Unless you are really
confident in what you are doing, I recommend using the constructors in
`Html.Attributes` and `Html.Events` (or `Svg.Attributes` and `Svg.Events`) to
ensure that the implementation used internally best matches the current spec.

[complicated reasons]: https://package.elm-lang.org/packages/elm/virtual-dom/latest/VirtualDom#Attribute

-}
addAttribute : VirtualDom.Attribute msg -> Element msg -> Element msg
addAttribute a =
  Internal.modify (\n -> { n | attributes = List.append n.attributes [a] })


{-| Adds an attribute to the current list when the condition is `True`
-}
addAttributeConditional : VirtualDom.Attribute msg -> Bool -> Element msg -> Element msg
addAttributeConditional a test =
  case test of
    True -> addAttribute a
    False -> (\x -> x)


{-| Adds a list of attributes to the current list
-}
addAttributeList : List (VirtualDom.Attribute msg) -> Element msg -> Element msg
addAttributeList la =
  Internal.modify (\n -> { n | attributes = List.append n.attributes la })


{-| Adds a list of attributes to the current list when the condition is `True`
-}
addAttributeListConditional : List (VirtualDom.Attribute msg) -> Bool -> Element msg -> Element msg
addAttributeListConditional la test =
  case test of
    True -> addAttributeList la
    False -> (\x -> x)


{-| Replaces the current list of attributes with a new list
-}
replaceAttributeList : List (VirtualDom.Attribute msg) -> Element msg -> Element msg
replaceAttributeList la =
  Internal.modify (\n -> { n | attributes = la })


-- EVENT LISTENERS

---- ACTIONS

{-| Adds an action to the current list of event listeners

As defined here, an *action* is a simple event listener that does nothing except
send a message to your Elm program's update function when the specified event is
triggered. This is useful for responding to events like "click", "mouseover",
"mouseout", and so on.

Event names in the DOM API are documented [here].

[here]: https://developer.mozilla.org/en-US/docs/Web/Events

-}
addAction : (String, msg) -> Element msg -> Element msg
addAction (event, msg) =
  let
    handler =
      Json.Decode.succeed
        >> VirtualDom.Normal

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ (event, handler msg) ] })


{-| Adds an action to the current list of event listeners when the condition is
`True`
-}
addActionConditional : (String, msg) -> Bool -> Element msg -> Element msg
addActionConditional kv test =
  case test of
    True -> addAction kv
    False -> (\x -> x)


{-| Adds an action to the current list of event listeners using the [Handler]
type `MayStopPropagation` with the option set to `True`

[Handler]: https://package.elm-lang.org/packages/elm/virtual-dom/latest/VirtualDom#Handler

-}
addActionStopPropagation : (String, msg) -> Element msg -> Element msg
addActionStopPropagation (event, msg) =
  let
    handler =
      Json.Decode.succeed
        >> Json.Decode.map (\x -> (x, True))
        >> VirtualDom.MayStopPropagation

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ (event, handler msg) ] })


{-| Adds an action to the current list of event listeners using the [Handler]
option `MayPreventDefault` with the option set to `True`

[Handler]: https://package.elm-lang.org/packages/elm/virtual-dom/latest/VirtualDom#Handler

-}
addActionPreventDefault : (String, msg) -> Element msg -> Element msg
addActionPreventDefault (event, msg) =
  let
    handler =
      Json.Decode.succeed
        >> Json.Decode.map (\x -> (x, True))
        >> VirtualDom.MayPreventDefault

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ (event, handler msg) ] })


{-| Adds an action to the current list of event listeners using the [Handler]
type `Custom` with both options set to `True`

[Handler]: https://package.elm-lang.org/packages/elm/virtual-dom/latest/VirtualDom#Handler

-}
addActionStopAndPrevent : (String, msg) -> Element msg -> Element msg
addActionStopAndPrevent (event, msg) =
  let
    handler =
      Json.Decode.succeed
        >> Json.Decode.map (\x ->
          { message = x
          , stopPropagation = True
          , preventDefault = True
          })
        >> VirtualDom.Custom

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ (event, handler msg) ] })


---- INPUT HANDLERS

{-| Adds an input handler for form elements to the current list of event
listeners

Internally, this function is equivalent to [Html.Events.onInput].

[Html.Events.onInput]: https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onInput

-}
addInputHandler : (String -> msg) -> Element msg -> Element msg
addInputHandler token =
  let
    handler =
      Internal.captureStopPropagation ("value", Json.Decode.string)

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ ("input", handler token) ] })


{-| Adds an input handler for form elements to the current list of event
listeners

The parser works as follows: when the "input" event is triggered, a `String` is
captured from `event.target.value`; then the parsing function is applied before
the resulting value is passed to your Elm program's update function. For simple
error handling, it is recommended to have your parsing function return a `Maybe`
value.

-}
addInputHandlerWithParser : (a -> msg, String -> a) -> Element msg -> Element msg
addInputHandlerWithParser (token, parser) =
  let
    handler =
      Internal.captureStopPropagation ("value", Json.Decode.string)

    transform =
      parser >> token

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ ("input", handler transform) ] })


{-| Adds value change handler for form elements to the current list of event
listeners

This handler captures `event.target.value` on a ["change"] event, which can
sometimes be useful when designing form interaction. Unlike the default input
handler, it does not invoke the "stopPropagation" option.

["change"]: https://developer.mozilla.org/en-US/docs/Web/Events/change

-}
addChangeHandler : (String -> msg) -> Element msg -> Element msg
addChangeHandler token =
  let
    handler =
      Internal.capture ("value", Json.Decode.string)

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ ("change", handler token) ] })


{-| Adds a value change handler for form elements to the current list of event
listeners

This handler captures `event.target.value` on a ["change"] event, which can
sometimes be useful when designing form interaction. Unlike the default input
handler, it does not invoke the "stopPropagation" option.

The parser works as follows: when the "change" event is triggered, a `String` is
captured from `event.target.value`; then the parsing function is applied before
the resulting value is passed to your Elm program's update function. For simple
error handling, it is recommended to have your parsing function return a `Maybe`
value.

["change"]: https://developer.mozilla.org/en-US/docs/Web/Events/change

-}
addChangeHandlerWithParser : (a -> msg, String -> a) -> Element msg -> Element msg
addChangeHandlerWithParser (token, parser) =
  let
    handler =
      Internal.capture ("value", Json.Decode.string)

    transform =
      parser >> token

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ ("change", handler transform) ] })


{-| Adds a toggle handler for checkboxes and radio buttons to the current list
of event listeners

Internally, this function is equivalent to [Html.Events.onCheck].

[Html.Events.onCheck]: https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onCheck

-}
addToggleHandler : (Bool -> msg) -> Element msg -> Element msg
addToggleHandler token =
  let
    handler =
      Internal.capture ("checked", Json.Decode.bool)

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ ("change", handler token) ] })


---- CUSTOM LISTENERS

{-| Adds a listener to the current list that will invoke a custom `Json` decoder
when the specified [event] is triggered.

The `VirtualDom` implementation for this function uses the [Handler] type
`Normal`.

[event]: https://developer.mozilla.org/en-US/docs/Web/Events
[Handler]: https://package.elm-lang.org/packages/elm/virtual-dom/latest/VirtualDom#Handler

-}
addListener : (String, Decoder msg) -> Element msg -> Element msg
addListener (event, decoder) =
  let
    handler =
      VirtualDom.Normal

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ (event, handler decoder) ] })


{-| Adds a listener to the current list (via `addListener`) when the condition
is `True`

-}
addListenerConditional : (String, Decoder msg) -> Bool -> Element msg -> Element msg
addListenerConditional kv test =
  case test of
    True -> addListener kv
    False -> (\x -> x)


{-| Adds a listener to the current list that will invoke a custom `Json` decoder
when the specified event is triggered

The `VirtualDom` implementation for this function uses the `Handler` type
`MayStopPropagation` with the option set to `True`.

-}
addListenerStopPropagation : (String, Decoder msg) -> Element msg -> Element msg
addListenerStopPropagation (event, decoder) =
  let
    handler =
      Json.Decode.map (\d -> (d, True))
        >> VirtualDom.MayStopPropagation

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ (event, handler decoder) ] })


{-| Adds a listener to the current list that will invoke a custom `Json` decoder
when the specified event is triggered

The `VirtualDom` implementation for this function uses the `Handler` type
`MayPreventDefault` with the option set to `True`.

-}
addListenerPreventDefault : (String, Decoder msg) -> Element msg -> Element msg
addListenerPreventDefault (event, decoder) =
  let
    handler =
      Json.Decode.map (\d -> (d, True))
        >> VirtualDom.MayPreventDefault

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ (event, handler decoder) ] })


{-| Adds a listener to the current list that will invoke a custom `Json` decoder
when the specified event is triggered

The `VirtualDom` implementation for this function uses the `Handler` type
`Custom` with both options set to `True`.

-}
addListenerStopAndPrevent : (String, Decoder msg) -> Element msg -> Element msg
addListenerStopAndPrevent (event, decoder) =
  let
    handler =
      Json.Decode.map (\x ->
        { message = x
        , stopPropagation = True
        , preventDefault = True
        }
      )
        >> VirtualDom.Custom

  in
    Internal.modify (\n -> { n | listeners = List.append n.listeners [ (event, handler decoder) ] })


{-| Removes all instances of a key (event name) from the current list of event
listeners
-}
removeListener : String -> Element msg -> Element msg
removeListener s =
  let
    isNotKey name (k, v) =
      k /= name

  in
    Internal.modify (\n -> { n | listeners = n.listeners |> List.filter (isNotKey s) })


-- INTERNAL TEXT

{-| Adds a string to the end of the current text
-}
appendText : String -> Element msg -> Element msg
appendText s =
  Internal.modify (\n -> { n | text = String.append n.text s })


{-| Adds a string to the end of the current text when the condition is `True`
-}
appendTextConditional : String -> Bool -> Element msg -> Element msg
appendTextConditional s test =
  case test of
    True -> appendText s
    False -> (\x -> x)


{-| Adds a string to the beginning of the current text
-}
prependText : String -> Element msg -> Element msg
prependText s =
  Internal.modify (\n -> { n | text = String.append s n.text })


{-| Adds a string to the beginning of the current text when the condition is
`True`
-}
prependTextConditional : String -> Bool -> Element msg -> Element msg
prependTextConditional s test =
  case test of
    True -> prependText s
    False -> (\x -> x)


{-| Replaces the current text with new text
-}
replaceText : String -> Element msg -> Element msg
replaceText s =
  Internal.modify (\n -> { n | text = s })


{-| Replaces the current text with new text when the condition is `True`
-}
replaceTextConditional : String -> Bool -> Element msg -> Element msg
replaceTextConditional s test =
  case test of
    True -> replaceText s
    False -> (\x -> x)


-- CHILD ELEMENTS

{-| Renders an element (the first argument) and adds it to the end of the
current child list (in the second argument)
-}
appendChild : Element msg -> Element msg -> Element msg
appendChild e =
  let
    r =
      Internal.render e

  in
    Internal.modify (\n -> { n | children = List.append n.children [r] })


{-| Renders an element and adds it to the end of the current child list when the
condition is true
-}
appendChildConditional : Element msg -> Bool -> Element msg -> Element msg
appendChildConditional e test =
  case test of
    True -> appendChild e
    False -> (\x -> x)


{-| Adds an `Html` node to the end of the the current child list
-}
appendNode : VirtualDom.Node msg -> Element msg -> Element msg
appendNode v =
  Internal.modify (\n -> { n | children = List.append n.children [v] })


{-| Renders a list of elements and adds them to the end of the current child
list
-}
appendChildList : List (Element msg) -> Element msg -> Element msg
appendChildList le =
  let
    lr =
      le |> List.map Internal.render

  in
    Internal.modify (\n -> { n | children = List.append n.children lr })


{-| Renders a list of elements and adds them to the end of the current child
list when the condition is `True`
-}
appendChildListConditional : List (Element msg) -> Bool -> Element msg -> Element msg
appendChildListConditional le test =
  case test of
    True -> appendChildList le
    False -> (\x -> x)


{-| Adds a list of `Html` nodes to the end of the the current child list
-}
appendNodeList : List (VirtualDom.Node msg) -> Element msg -> Element msg
appendNodeList lv =
  Internal.modify (\n -> { n | children = List.append n.children lv })


{-| Renders an element and adds it to the beginning of the current child list
-}
prependChild : Element msg -> Element msg -> Element msg
prependChild e =
  let
    r =
      Internal.render e

  in
    Internal.modify (\n -> { n | children = r :: n.children })


{-| Renders an element and adds it to the beginning of the current child list
when the condition is `True`
-}
prependChildConditional : Element msg -> Bool -> Element msg -> Element msg
prependChildConditional e test =
  case test of
    True -> prependChild e
    False -> (\x -> x)


{-| Adds an `Html` node to the beginning of the the current child list
-}
prependNode : VirtualDom.Node msg -> Element msg -> Element msg
prependNode v =
  Internal.modify (\n -> { n | children = v :: n.children })


{-| Renders a list of elements and adds them to the beginning of the current
child list
-}
prependChildList : List (Element msg) -> Element msg -> Element msg
prependChildList le =
  let
    lr =
      le |> List.map Internal.render

  in
    Internal.modify (\n -> { n | children = List.append lr n.children })


{-| Renders a list of elements and adds them to the beginning of the current child list
when the condition is `True`
-}
prependChildListConditional : List (Element msg) -> Bool -> Element msg -> Element msg
prependChildListConditional le test =
  case test of
    True -> prependChildList le
    False -> (\x -> x)


{-| Adds a list of `Html` nodes to the beginning of the the current child list
-}
prependNodeList : List (VirtualDom.Node msg) -> Element msg -> Element msg
prependNodeList lv =
  Internal.modify (\n -> { n | children = List.append lv n.children })


{-| Renders a list of elements replaces the current child list with the rendered
list
-}
replaceChildList : List (Element msg) -> Element msg -> Element msg
replaceChildList le =
  let
    lr =
      le |> List.map Internal.render

  in
    Internal.modify (\n -> { n | children = lr })


{-| Replaces the current child list with the rendered list when the condition is
`True`
-}
replaceChildListConditional : List (Element msg) -> Bool -> Element msg -> Element msg
replaceChildListConditional le test =
  case test of
    True -> replaceChildList le
    False -> (\x -> x)


{-| Replaces the current child list with a list of `Html` nodes
-}
replaceNodeList : List (VirtualDom.Node msg) -> Element msg -> Element msg
replaceNodeList ln =
  Internal.modify (\n -> { n | children = ln })


{-| Sets or resets the current child list from a keyed list of element records

This is a performance optimization that will flag the rendering function to use
[keyedNode] or [keyedNodeNS]. See [here] for details.

[keyedNode]: https://package.elm-lang.org/packages/elm/virtual-dom/latest/VirtualDom#keyedNode
[keyedNodeNS]: https://package.elm-lang.org/packages/elm/virtual-dom/latest/VirtualDom#keyedNodeNS
[here]: https://guide.elm-lang.org/optimization/keyed.html

-}
setChildListWithKeys : List (String, Element msg) -> Element msg -> Element msg
setChildListWithKeys lkv =
  let
    (ls, le) =
      List.unzip lkv

    lr =
      le |> List.map Internal.render

  in
    Internal.modify (\n -> { n | children = lr, keys = ls })


{-| Sets or resets the current child list from a keyed list of `Html` nodes

This is a performance optimization that will flag the rendering function to use
[keyedNode] or [keyedNodeNS]. See [here] for details.

[keyedNode]: https://package.elm-lang.org/packages/elm/virtual-dom/latest/VirtualDom#keyedNode
[keyedNodeNS]: https://package.elm-lang.org/packages/elm/virtual-dom/latest/VirtualDom#keyedNodeNS
[here]: https://guide.elm-lang.org/optimization/keyed.html

-}
setNodeListWithKeys : List (String, VirtualDom.Node msg) -> Element msg -> Element msg
setNodeListWithKeys lkv =
  let
    (ls, ln) =
      List.unzip lkv

  in
    Internal.modify (\n -> { n | children = ln, keys = ls })


-- TAG and NAMESPACE

{-| Sets or resets the HTML tag

This is generally unnecessary because the tag is set by the `element`
constructor; it may be useful to have when working with component libraries
based on this package.

-}
setTag : String -> Element msg -> Element msg
setTag s =
  Internal.modify (\n -> { n | tag = s })


{-| Sets the XML namespace as described [here]

This is required when using `Element` records to construct SVG nodes.

[here]: https://package.elm-lang.org/packages/elm/virtual-dom/latest/VirtualDom#nodeNS
-}
setNamespace : String -> Element msg -> Element msg
setNamespace s =
  Internal.modify (\n -> { n | namespace = s })


---- DEBUGGING ----

{-| Returns a record containing the `Element`'s internal data
-}
getData : Element msg -> Internal.Data msg
getData n =
  case n of
    Internal.Element data -> data
