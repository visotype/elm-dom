module Capture exposing (main)


import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Dom


main : Program () Value Capture
main =
  { init = { input = "", change = "" }
  , view = view
  , update = update
  }
    |> Browser.sandbox


-- model type alias

type alias Value =
  { input : String
  , change : String
  }


-- message type

type Capture
  = OnInput String
  | OnChange String


-- UPDATE --

update : Capture -> Value -> Value
update capture current =
  case capture of
    OnInput string -> { current | input = string }
    OnChange string -> { current | change = string }


-- VIEW --

view : Value -> Html Capture
view value =
  container "Capture.elm"
    |> Dom.appendChild (example value)
    |> Dom.render


-- main interactive component

example : Value -> Dom.Element Capture
example value =
  let
    inputGroup =
      Dom.element "div"
        |> Dom.addClassList
          [ "form-group"
          , "my-2"
          ]
        |> Dom.appendChildList
          [ inputField "type something here"
            |> Dom.addInputHandler OnInput
            |> Dom.addChangeHandler OnChange
          , helpText "danger"
            |> Dom.appendTextConditional
              "Now click somewhere else on the page"
              (value.input /= "" && value.change /= value.input)
          ]

    labelText string =
      Dom.element "p"
        |> Dom.addClass "my-0"
        |> Dom.addStyleList
          [ ("line-height", "1em")
          , ("min-height", "1em")
          ]
        |> Dom.appendText string

    outputText string =
      Dom.element "p"
        |> Dom.addClass "my-0"
        |> Dom.addStyle ("height", "1.5rem")
        |> Dom.appendText string

    contextClass text =
      case text of
        "" -> "secondary"
        _ -> "success"

    groupedFields =
      [ ( inputGroup
        , ""
        )
      , ( labelText "Updates on \"input\":"
        , "dark"
        )
      , ( outputText value.input
        , contextClass value.input
        )
      , ( labelText "Updates on \"change\":"
        , "dark"
        )
      , ( outputText value.change
        , contextClass value.change
        )
      ]
        |> listGroup

  in
    Dom.element "div"
      |> Dom.addClassList
        [ "p-4"
        , "text-center"
        , "bg-light"
        , "rounded"
        ]
      |> Dom.appendChild groupedFields


-- simple reusable components

container : String -> Dom.Element msg
container title =
  let
    heading =
      Dom.element "h1"
        |> Dom.addClass "pb-3"
        |> Dom.appendText title

  in
    Dom.element "div"
      |> Dom.addClassList
        [ "mx-auto"
        , "my-4"
        , "p-4"
        , "border"
        , "rounded"
        ]
      |> Dom.addStyleList
        [ ("maxWidth", "500px")
        , ("height", "550px")
        ]
      |> Dom.appendChild heading


inputField : String -> Dom.Element msg
inputField placeholder =
  Dom.element "input"
    |> Dom.addClass "form-control"
    |> Dom.addAttributeList
      [ Attr.type_ "text"
      , Attr.placeholder placeholder
      ]


helpText : String -> Dom.Element msg
helpText context =
  Dom.element "small"
    |> Dom.addClassList
      [ "form-text"
      , "text-left"
      , "text-" ++ context
      ]
    |> Dom.addStyle ("height", "1em")


listGroup : List (Dom.Element msg, String) -> Dom.Element msg
listGroup items =
  let
    toGroupItem (content, context) =
      Dom.element "li"
        |> Dom.addClass "list-group-item"
        |> Dom.addClassConditional ("list-group-item-" ++ context) (context /= "")
        |> Dom.appendChild content

  in
    Dom.element "ul"
      |> Dom.addClass "list-group"
      |> Dom.appendChildList (items |> List.map toGroupItem)
