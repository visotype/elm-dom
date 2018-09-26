module Tests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)

import Dom
import Dom.Internal

import VirtualDom
import Html
import Html.Attributes as Attr
import Html.Events as Event
import Html.Keyed as Keyed
import Json.Decode


-- HELPERS --

{-| Construct an empty div for testing
-}
div : Dom.Internal.Data msg
div =
  { tag = "div"
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


testString1 = "abc123"
testString2 = "xyz678"
testString3 = "quv999"
testString4 = "rst555"


type TestMsg
  = DoSomething
  | CaptureString String
  | CaptureInt (Maybe Int)
  | CaptureBool Bool


testDecoder : (String -> TestMsg) -> Json.Decode.Decoder TestMsg
testDecoder token =
  Json.Decode.string
    |> Json.Decode.at ["target", "id"]
    |> Json.Decode.map token


-- TESTS --


suite : Test
suite =
  [ recordEquality
    |> describe "Do comparisons of Elm records give the expected results?"

  , nodeEquality
    |> describe "Do comparisons of VirtualDom nodes give the expected results?"

  , [ tag
      |> describe "Do updates to the `tag` field give the expected results?"

    , id
      |> describe "Do updates to the `id` field give the expected results?"

    , classes
      |> describe "Do updates to the `classes` field give the expected results?"

    , styles
      |> describe "Do updates to the `styles` field give the expected results?"

    , listeners
      |> describe "Do updates to the `listeners` field give the expected results?"

    , attributes
      |> describe "Do updates to the `attributes` field give the expected results?"

    , text
      |> describe "Do updates to the `text` field give the expected results?"

    , children
      |> describe "Do updates to the `children` field give the expected results?"

    , namespace
      |> describe "Do updates to the `namespace` field give the expected results?"

    , keys
      |> describe "Do updates to the `keys` field give the expected results?"

    ]
      |> describe "Do `Element` record update functions give the expected results?"

  ]
    |> describe "Testing `Dom.elm`"


recordEquality : List Test
recordEquality =
  [ ( \() ->
      Dom.element "div"
        |> Dom.getData
        |> Expect.equal div
    )
      |> test "Element records with the same tag and no other data should be equal"

  , ( \() ->
      Dom.element "button"
        |> Dom.getData
        |> Expect.notEqual div
    )
      |> test "Element records with different tags should not be equal"

  , ( \() ->
      { div | classes = [ testString1, testString2 ] }
        |> Expect.notEqual { div | classes = [ testString2, testString1 ] }
    )
      |> test "Records should not be equal if listed items are in a different order"

  ]


nodeEquality : List Test
nodeEquality =
  [ ( \() ->
      Dom.element "div"
        |> Dom.render
        |> Expect.equal (Html.div [] [])
    )
      |> test "Rendered nodes with the same tag and no other data should be equal"

  , ( \() ->
      Dom.element "button"
        |> Dom.render
        |> Expect.notEqual (Html.div [] [])
    )
      |> test "Rendered nodes with different tags should not be equal"

  , ( \() ->
      Dom.element "div"
        |> Dom.addClass "container"
        |> Dom.render
        |> Expect.equal (Html.div [Attr.class "container"] [])
    )
      |> test "Rendered nodes with the same attribute value and no other data should be equal"

  , ( \() ->
      Dom.element "div"
        |> Dom.addClass "column"
        |> Dom.render
        |> Expect.notEqual (Html.div [Attr.class "container"] [])
    )
      |> test "Rendered nodes with different values for an attribute should not be equal"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "p")
        |> Dom.render
        |> Expect.equal (Html.div [] [ Html.p [] [] ])
    )
      |> test "Rendered nodes containing child nodes with the same tag and no other data should be equal"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.render
        |> Expect.notEqual (Html.div [] [ Html.p [] [] ])
    )
      |> test "Rendered nodes containing child nodes with different tags should not be equal"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild
          ( Dom.element "p"
            |> Dom.appendChild (Dom.element "span" |> Dom.appendText "something")
          )
        |> Dom.render
        |> Expect.equal (Html.div [] [ Html.p [] [ Html.span [] [ Html.text "something" ] ] ])
    )
      |> test "Records containing equivalent child nodes with identical descendant trees should be equal"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild
          ( Dom.element "p"
            |> Dom.appendChild (Dom.element "span" |> Dom.appendText "something else")
          )
        |> Dom.render
        |> Expect.notEqual (Html.div [] [ Html.p [] [ Html.span [] [ Html.text "something" ] ] ])
    )
      |> test "Records containing equivalent child nodes with diverging descendant trees should not be equal"

  ]


tag : List Test
tag =
  [ ( \() ->
      Dom.element "div"
        |> Dom.setTag "span"
        |> Dom.render
        |> Expect.equal (Html.span [] [])
    )
      |> test "Dom.setTag"

  ]


id : List Test
id =
  [ ( \() ->
      Dom.element "div"
        |> Dom.setId testString1
        |> Dom.render
        |> Expect.equal (Html.div [Attr.id testString1] [])
    )
      |> test "Dom.setId"

  ]


classes : List Test
classes =
  [ ( \() ->
      Dom.element "div"
        |> Dom.addClass testString1
        |> Dom.render
        |> Expect.equal (Html.div [Attr.class testString1] [])
    )
      |> test "Dom.addClass"

  , ( \() ->
      Dom.element "div"
        |> Dom.addClass testString1
        |> Dom.addClassConditional testString2 True
        |> Dom.render
        |> Expect.equal (Html.div [Attr.class testString1, Attr.class testString2] [])
    )
      |> test "Dom.addClassConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.addClass testString1
        |> Dom.addClassConditional testString2 False
        |> Dom.render
        |> Expect.equal (Html.div [Attr.class testString1] [])
    )
      |> test "Dom.addClassConditional: condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.addClass testString1
        |> Dom.addClassList [ testString2, testString3 ]
        |> Dom.render
        |> Expect.equal (Html.div [Attr.class testString1, Attr.class testString2, Attr.class testString3] [])
    )
      |> test "Dom.addClassList"

  , ( \() ->
      Dom.element "div"
        |> Dom.addClassListConditional [ testString1, testString2 ] True
        |> Dom.render
        |> Expect.equal (Html.div [Attr.class testString1, Attr.class testString2] [])
    )
      |> test "Dom.addClassListConditional: condtion is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.addClassListConditional [ testString1, testString2 ] False
        |> Dom.render
        |> Expect.equal (Html.div [] [])
    )
      |> test "Dom.addClassListConditional: condtion is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.addClassList [ testString1, testString2, testString1 ]
        |> Dom.removeClass testString1
        |> Dom.render
        |> Expect.equal (Html.div [Attr.class testString2] [])
    )
      |> test "Dom.removeClass"

  , ( \() ->
      Dom.element "div"
        |> Dom.addClassList [ testString1, testString2 ]
        |> Dom.replaceClassList [ testString3, testString4 ]
        |> Dom.render
        |> Expect.equal (Html.div [Attr.class testString3, Attr.class testString4] [])
    )
      |> test "Dom.replaceClassList"

  ]


styles : List Test
styles =
  [ ( \() ->
      Dom.element "div"
        |> Dom.addStyle (testString1, testString2)
        |> Dom.render
        |> Expect.equal (Html.div [Attr.style testString1 testString2] [])
    )
      |> test "Dom.addstyle"

  , ( \() ->
      Dom.element "div"
        |> Dom.addStyle (testString1, testString2)
        |> Dom.addStyleConditional (testString3, testString4) True
        |> Dom.render
        |> Expect.equal (Html.div [Attr.style testString1 testString2, Attr.style testString3 testString4] [])
    )
      |> test "Dom.addStyleConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.addStyle (testString1, testString2)
        |> Dom.addStyleConditional (testString3, testString4) False
        |> Dom.render
        |> Expect.equal (Html.div [Attr.style testString1 testString2] [])
    )
      |> test "Dom.addStyleConditional: condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.addStyleList [ (testString1, testString2), (testString3, testString4) ]
        |> Dom.render
        |> Expect.equal (Html.div [Attr.style testString1 testString2, Attr.style testString3 testString4] [])
    )
      |> test "Dom.addStyleList"

  , ( \() ->
      Dom.element "div"
        |> Dom.addStyleListConditional [ (testString1, testString2), (testString3, testString4) ] True
        |> Dom.render
        |> Expect.equal (Html.div [Attr.style testString1 testString2, Attr.style testString3 testString4] [])
    )
      |> test "Dom.addStyleListConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.addStyleListConditional [ (testString1, testString2), (testString3, testString4) ] False
        |> Dom.render
        |> Expect.equal (Html.div [] [])
    )
      |> test "Dom.addStyleListConditional: condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.addStyleList [ (testString1, testString2), (testString3, testString4), (testString1, testString4) ]
        |> Dom.removeStyle testString1
        |> Dom.render
        |> Expect.equal (Html.div [Attr.style testString3 testString4] [])
    )
      |> test "Dom.removeStyle"

  , ( \() ->
      Dom.element "div"
        |> Dom.addStyleList [ (testString1, testString2) ]
        |> Dom.replaceStyleList [ (testString3, testString4) ]
        |> Dom.render
        |> Expect.equal (Html.div [Attr.style testString3 testString4] [])
    )
      |> test "Dom.replaceStyleList"

  ]


listeners : List Test
listeners =
  [ ( \() ->
      Dom.element "div"
        |> Dom.addAction ("click", DoSomething)
        |> Dom.render
        |> Expect.equal (Html.div [Event.onClick DoSomething] [])
    )
      |> test "Dom.addAction"

  , ( \() ->
      Dom.element "div"
        |> Dom.addActionConditional ("click", DoSomething) True
        |> Dom.render
        |> Expect.equal (Html.div [Event.onClick DoSomething] [])
    )
      |> test "Dom.addActionConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.addActionConditional ("click", DoSomething) False
        |> Dom.render
        |> Expect.equal (Html.div [] [])
    )
      |> test "Dom.addActionConditional: condition is False"

  -- Using List.length because Elm compiler won't evaluate comparison on functions
  , ( \() ->
      Dom.element "div"
        |> Dom.addInputHandler CaptureString
        |> Dom.getData >> .listeners
        |> List.length
        |> Expect.equal 1
    )
      |> test "Dom.addInputHandler"

  -- Using List.length because Elm compiler won't evaluate comparison on functions
  , ( \() ->
      Dom.element "div"
        |> Dom.addInputHandlerWithParser (CaptureInt, String.toInt)
        |> Dom.getData >> .listeners
        |> List.length
        |> Expect.equal 1
    )
      |> test "Dom.addInputHandlerWithParser"

  -- Using List.length because Elm compiler won't evaluate comparison on functions
  , ( \() ->
      Dom.element "div"
        |> Dom.addChangeHandler CaptureString
        |> Dom.getData >> .listeners
        |> List.length
        |> Expect.equal 1
    )
      |> test "Dom.addChangeHandler"

    -- Using List.length because Elm compiler won't evaluate comparison on functions
    , ( \() ->
        Dom.element "div"
          |> Dom.addChangeHandlerWithParser (CaptureInt, String.toInt)
          |> Dom.getData >> .listeners
          |> List.length
          |> Expect.equal 1
      )
        |> test "Dom.addChangeHandlerWithParser"

    -- Using List.length because Elm compiler won't evaluate comparison on functions
    , ( \() ->
        Dom.element "div"
          |> Dom.addToggleHandler CaptureBool
          |> Dom.getData >> .listeners
          |> List.length
          |> Expect.equal 1
      )
        |> test "Dom.addToggleHandler"

    -- Using List.length because Elm compiler won't evaluate comparison on functions
    , ( \() ->
        Dom.element "div"
          |> Dom.addListener ("mouseover", testDecoder CaptureString)
          |> Dom.getData >> .listeners
          |> List.length
          |> Expect.equal 1
      )
        |> test "Dom.addListener"

    -- Using List.length because Elm compiler won't evaluate comparison on functions
    , ( \() ->
        Dom.element "div"
          |> Dom.addListenerConditional ("mouseover", testDecoder CaptureString) True
          |> Dom.getData >> .listeners
          |> List.length
          |> Expect.equal 1
      )
        |> test "Dom.addListener: condition is True"

    -- Using List.length because Elm compiler won't evaluate comparison on functions
    , ( \() ->
        Dom.element "div"
          |> Dom.addListenerConditional ("mouseover", testDecoder CaptureString) False
          |> Dom.getData >> .listeners
          |> List.length
          |> Expect.equal 0
      )
        |> test "Dom.addListener: condition is False"

    -- Using List.length because Elm compiler won't evaluate comparison on functions
    , ( \() ->
        Dom.element "div"
          |> Dom.addListenerStopPropagation ("mouseover", testDecoder CaptureString)
          |> Dom.getData >> .listeners
          |> List.length
          |> Expect.equal 1
      )
        |> test "Dom.addListenerStopPropagation"

    -- Using List.length because Elm compiler won't evaluate comparison on functions
    , ( \() ->
        Dom.element "div"
          |> Dom.addListenerPreventDefault ("mouseover", testDecoder CaptureString)
          |> Dom.getData >> .listeners
          |> List.length
          |> Expect.equal 1
      )
        |> test "Dom.addListenerPreventDefault"

    -- Using List.length because Elm compiler won't evaluate comparison on functions
    , ( \() ->
        Dom.element "div"
          |> Dom.addListenerStopAndPrevent ("mouseover", testDecoder CaptureString)
          |> Dom.getData >> .listeners
          |> List.length
          |> Expect.equal 1
      )
        |> test "Dom.addListenerStopAndPrevent"

    , ( \() ->
        Dom.element "div"
          |> Dom.addAction ("click", DoSomething)
          |> Dom.addListener ("mouseover", testDecoder CaptureString)
          |> Dom.removeListener "mouseover"
          |> Dom.render
          |> Expect.equal (Html.div [Event.onClick DoSomething] [])
      )
        |> test "Dom.removeListener"

  ]


attributes : List Test
attributes =
  [ ( \() ->
      Dom.element "div"
        |> Dom.addAttribute (Attr.name testString1)
        |> Dom.render
        |> Expect.equal (Html.div [Attr.name testString1] [])
    )
      |> test "Dom.addAttribute"

  , ( \() ->
      Dom.element "div"
        |> Dom.addAttribute (Attr.name testString1)
        |> Dom.addAttributeConditional (Attr.title testString2) True
        |> Dom.render
        |> Expect.equal (Html.div [Attr.name testString1, Attr.title testString2] [])
    )
      |> test "Dom.addAttributeConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.addAttribute (Attr.name testString1)
        |> Dom.addAttributeConditional (Attr.title testString2) False
        |> Dom.render
        |> Expect.equal (Html.div [Attr.name testString1] [])
    )
      |> test "Dom.addAttributeConditional: condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.addAttributeList
          [ Attr.name testString1
          , Attr.title testString2
          ]
        |> Dom.render
        |> Expect.equal (Html.div [Attr.name testString1, Attr.title testString2] [])
    )
      |> test "Dom.addAttributeList"

  , ( \() ->
      Dom.element "div"
        |> Dom.addAttributeListConditional
          [ Attr.name testString1
          , Attr.title testString2
          ]
          True
        |> Dom.render
        |> Expect.equal (Html.div [Attr.name testString1, Attr.title testString2] [])
    )
      |> test "Dom.addAttributeListConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.addAttributeListConditional
          [ Attr.name testString1
          , Attr.title testString2
          ]
          False
        |> Dom.render
        |> Expect.equal (Html.div [] [])
    )
      |> test "Dom.addAttributeListConditional: condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.addAttributeList
          [ Attr.name testString1
          , Attr.title testString2
          ]
        |> Dom.replaceAttributeList
          [ Attr.name testString3
          , Attr.title testString4
          ]
        |> Dom.render
        |> Expect.equal (Html.div [Attr.name testString3, Attr.title testString4] [])
    )
      |> test "Dom.replaceAttributeList"

  ]


text : List Test
text =
  [ ( \() ->
      Dom.element "div"
        |> Dom.appendText testString1
        |> Dom.appendText testString2
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.text (testString1 ++ testString2)])
    )
      |> test "Dom.appendText"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendText testString1
        |> Dom.appendTextConditional testString2 True
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.text (testString1 ++ testString2)])
    )
      |> test "Dom.appendTextConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendText testString1
        |> Dom.appendTextConditional testString2 False
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.text testString1])
    )
      |> test "Dom.appendTextConditional: condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendText testString2
        |> Dom.prependText testString1
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.text (testString1 ++ testString2)])
    )
      |> test "Dom.prependText"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendText testString2
        |> Dom.prependTextConditional testString1 True
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.text (testString1 ++ testString2)])
    )
      |> test "Dom.prependTextConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendText testString2
        |> Dom.prependTextConditional testString1 False
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.text testString2])
    )
      |> test "Dom.prependTextConditional: condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendText testString1
        |> Dom.replaceText testString2
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.text testString2])
    )
      |> test "Dom.replaceText"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendText testString1
        |> Dom.replaceTextConditional testString2 True
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.text testString2])
    )
      |> test "Dom.replaceTextConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendText testString1
        |> Dom.replaceTextConditional testString2 False
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.text testString1])
    )
      |> test "Dom.replaceTextConditional: condition is False"

  ]


children : List Test
children =
  [ ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "p")
        |> Dom.appendChild (Dom.element "span")
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.p [] [], Html.span [] []])
    )
      |> test "Dom.appendChild"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "p")
        |> Dom.appendChildConditional (Dom.element "span") True
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.p [] [], Html.span [] []])
    )
      |> test "Dom.appendChildConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "p")
        |> Dom.appendChildConditional (Dom.element "span") False
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.p [] []])
    )
      |> test "Dom.appendChildConditional: condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "p")
        |> Dom.appendNode (Html.span [] [])
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.p [] [], Html.span [] []])
    )
      |> test "Dom.appendNode"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.appendChildList
          [ Dom.element "p"
          , Dom.element "span"
          ]
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.button [] [], Html.p [] [], Html.span [] []])
    )
      |> test "Dom.appendChildList"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.appendChildListConditional
          [ Dom.element "p"
          , Dom.element "span"
          ]
          True
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.button [] [], Html.p [] [], Html.span [] []])
    )
      |> test "Dom.appendChildListConditional: Condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.appendChildListConditional
          [ Dom.element "p"
          , Dom.element "span"
          ]
          False
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.button [] []])
    )
      |> test "Dom.appendChildListConditional: Condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.appendNodeList
          [ Html.p [] []
          , Html.span [] []
          ]
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.button [] [], Html.p [] [], Html.span [] []])
    )
      |> test "Dom.appendNodeList"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "p")
        |> Dom.prependChild (Dom.element "span")
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.span [] [], Html.p [] []])
    )
      |> test "Dom.prependChild"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "p")
        |> Dom.prependChildConditional (Dom.element "span") True
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.span [] [], Html.p [] []])
    )
      |> test "Dom.prependChildConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "p")
        |> Dom.prependChildConditional (Dom.element "span") False
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.p [] []])
    )
      |> test "Dom.prependChildConditional: condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "p")
        |> Dom.prependNode (Html.span [] [])
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.span [] [], Html.p [] []])
    )
      |> test "Dom.prependNode"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.prependChildList
          [ Dom.element "p"
          , Dom.element "span"
          ]
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.p [] [], Html.span [] [], Html.button [] []])
    )
      |> test "Dom.prependChildList"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.prependChildListConditional
          [ Dom.element "p"
          , Dom.element "span"
          ]
          True
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.p [] [], Html.span [] [], Html.button [] []])
    )
      |> test "Dom.prependChildListConditional: Condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.prependChildListConditional
          [ Dom.element "p"
          , Dom.element "span"
          ]
          False
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.button [] []])
    )
      |> test "Dom.prependChildListConditional: Condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.prependNodeList
          [ Html.p [] []
          , Html.span [] []
          ]
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.p [] [], Html.span [] [], Html.button [] []])
    )
      |> test "Dom.prependNodeList"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.replaceChildList
          [ Dom.element "p"
          , Dom.element "span"
          ]
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.p [] [], Html.span [] []])
    )
      |> test "Dom.replaceChildList"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.replaceChildListConditional
          [ Dom.element "p"
          , Dom.element "span"
          ]
          True
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.p [] [], Html.span [] []])
    )
      |> test "Dom.replaceChildListConditional: condition is True"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.replaceChildListConditional
          [ Dom.element "p"
          , Dom.element "span"
          ]
          False
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.button [] []])
    )
      |> test "Dom.replaceChildListConditional: condition is False"

  , ( \() ->
      Dom.element "div"
        |> Dom.appendChild (Dom.element "button")
        |> Dom.replaceNodeList
          [ Html.p [] []
          , Html.span [] []
          ]
        |> Dom.render
        |> Expect.equal (Html.div [] [Html.p [] [], Html.span [] []])
    )
      |> test "Dom.replaceNodeList"

  ]


namespace : List Test
namespace =
  [ ( \() ->
      Dom.element "div"
        |> Dom.setNamespace testString1
        |> Dom.render
        |> Expect.equal (VirtualDom.nodeNS testString1 "div" [] [])
    )
      |> test "Dom.setNamespace"

  ]


keys : List Test
keys =
  [ ( \() ->
      Dom.element "div"
        |> Dom.setChildListWithKeys
          [ (testString1, Dom.element "p")
          , (testString2, Dom.element "span")
          , (testString3, Dom.element "button")
          ]
        |> Dom.render
        |> Expect.equal
          ( Keyed.node "div" []
            [ (testString1, Html.p [] [])
            , (testString2, Html.span [] [])
            , (testString3, Html.button [] [])
            ]
          )
    )
      |> test "Dom.setChildListWithKeys"

  , ( \() ->
      Dom.element "div"
        |> Dom.setNodeListWithKeys
          [ (testString1, Html.p [] [])
          , (testString2, Html.span [] [])
          , (testString3, Html.button [] [])
          ]
        |> Dom.render
        |> Expect.equal
          ( Keyed.node "div" []
            [ (testString1, Html.p [] [])
            , (testString2, Html.span [] [])
            , (testString3, Html.button [] [])
            ]
          )
    )
      |> test "Dom.setNodeListWithKeys"

  ]
