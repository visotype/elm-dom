module Dom.Internal exposing
  ( Element(..)
  , Data
  , modify
  , render
  , capture
  , captureStopPropagation
  , capturePreventDefault
  , captureStopAndPrevent
  )

{-| This module is exposed so that package developers can make use of `Element`
record internals. It is not recommended for use in application code.

# Internal Types
@docs Element
@docs Data

# Internal Functions
@docs modify
@docs render

# Internal Helpers for Event Handling
@docs capture
@docs captureStopPropagation
@docs capturePreventDefault
@docs captureStopAndPrevent

-}


import VirtualDom
import Json.Decode
import Json.Encode


{-| The type exposed by `Dom.elm`. You can think of this as an abstraction of
[Element](https://developer.mozilla.org/en-US/docs/Web/API/Element) in the
[Document Object Model](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model/Introduction)
(DOM) interface to HTML and XML documents.
-}
type Element msg =
  Element (Data msg)


{-| An `Element`'s internal data. This is just a record containing all of the
information needed to construct a `VirtualDom` node.
-}
type alias Data msg =
  { tag : String
  , id : String
  , classes : List String
  , styles : List (String, String)
  , listeners: List (String, VirtualDom.Handler msg)
  , attributes : List (VirtualDom.Attribute msg)
  , text : String
  , children : List (VirtualDom.Node msg)
  , namespace : String
  , keys : List String
  }


{-| Modify an `Element`'s internal data by applying a record update function
-}
modify : (Data msg -> Data msg) -> Element msg -> Element msg
modify f (Element data) =
  Element (f data)


{-| Construct a `VirtualDom.Handler` that captures input by proving the name of
a field at `event.target` to capture, a decoder to read that field, and a
message token to pass the result to the Elm program's update function
-}
capture : (String, Json.Decode.Decoder a) -> (a -> msg) -> VirtualDom.Handler msg
capture (field, decoder) token =
  decoder
    |> Json.Decode.at ["target", field]
    |> Json.Decode.map token
    |> VirtualDom.Normal


{-| Construct a `VirtualDom.Handler` with `MayStopPropagation` set to `True`
-}
captureStopPropagation : (String, Json.Decode.Decoder a) -> (a -> msg) -> VirtualDom.Handler msg
captureStopPropagation (field, decoder) token =
  decoder
    |> Json.Decode.at ["target", field]
    |> Json.Decode.map token
    |> Json.Decode.map (\x -> (x, True))
    |> VirtualDom.MayStopPropagation


{-| Construct a `VirtualDom.Handler` with `MayPreventDefault` set to `True`
-}
capturePreventDefault : (String, Json.Decode.Decoder a) -> (a -> msg) -> VirtualDom.Handler msg
capturePreventDefault (field, decoder) token =
  decoder
    |> Json.Decode.at ["target", field]
    |> Json.Decode.map token
    |> Json.Decode.map (\x -> (x, True))
    |> VirtualDom.MayPreventDefault


{-| Construct a `VirtualDom.Handler` with both `Custom` options set to `True`
-}
captureStopAndPrevent : (String, Json.Decode.Decoder a) -> (a -> msg) -> VirtualDom.Handler msg
captureStopAndPrevent (field, decoder) token =
  decoder
    |> Json.Decode.at ["target", field]
    |> Json.Decode.map token
    |> Json.Decode.map (\x ->
      { message = x
      , stopPropagation = True
      , preventDefault = True
      })
    |> VirtualDom.Custom


{-| Internal render function
-}
render : Element msg -> VirtualDom.Node msg
render (Element data) =
  let
    consId =
      case data.id of
        "" ->
          (\x -> x)

        _ ->
          data.id
            |> Json.Encode.string
            |> VirtualDom.property "id"
            |> (::)

    consClassName =
      case data.classes of
        [] ->
          (\x -> x)

        _ ->
          data.classes
            |> String.join " "
            |> Json.Encode.string
            |> VirtualDom.property "className"
            |> (::)

    prependStyles =
      case data.styles of
        [] ->
          (\x -> x)

        _ ->
          data.styles
            |> List.map (\(k, v) -> VirtualDom.style k v)
            |> List.append


    prependListeners =
      case data.listeners of
        [] ->
          (\x -> x)

        _ ->
          data.listeners
            |> List.map (\(k, v) -> VirtualDom.on k v)
            |> List.append


    consText =
      case data.text of
          "" ->
            (\x -> x)

          _ ->
            data.text
              |> VirtualDom.text
              |> (::)

    consTextKeyed =
      case data.text of
          "" ->
            (\x -> x)

          _ ->
            data.text
              |> VirtualDom.text
              |> Tuple.pair "rendered-internal-text"
              |> (::)

    allAttributes =
      data.attributes
        |> prependListeners
        |> prependStyles
        |> consClassName
        |> consId

  in
    case (data.namespace, data.keys)  of
      ("", []) ->
        data.children
          |> consText
          |> VirtualDom.node data.tag allAttributes

      (_, []) ->
        data.children
          |> consText
          |> VirtualDom.nodeNS data.namespace data.tag allAttributes

      ("", _) ->
        data.children
          |> List.map2 Tuple.pair data.keys
          |> consTextKeyed
          |> VirtualDom.keyedNode data.tag allAttributes

      (_, _) ->
        data.children
          |> List.map2 Tuple.pair data.keys
          |> consTextKeyed
          |> VirtualDom.keyedNodeNS data.namespace data.tag allAttributes
