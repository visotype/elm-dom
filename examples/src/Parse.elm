module Parse exposing (main)


import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Dom


main : Program () Value Capture
main =
  { init = { int = Nothing, float = Nothing }
  , view = view
  , update = update
  }
    |> Browser.sandbox


-- model type alias

type alias Value =
  { int : Maybe Int
  , float : Maybe Float
  }


-- message type

type Capture
  = ParseInt (Maybe Int)
  | ParseFloat (Maybe Float)


-- UPDATE --

update : Capture -> Value -> Value
update capture current =
  case capture of
    ParseInt maybeInt -> { current | int = maybeInt }
    ParseFloat maybeFloat -> { current | float = maybeFloat }


-- VIEW --

view : Value -> Html Capture
view value =
  container "Parse.elm"
    |> Dom.appendChild (example value)
    |> Dom.render


-- main interactive component

example : Value -> Dom.Element Capture
example value =
  let
    intInput =
      Dom.element "div"
        |> Dom.appendChild
          ( inputField "enter an integer"
            |> Dom.addClass "my-3"
            |> Dom.addInputHandlerWithParser (ParseInt, String.toInt)
          )

    floatInput =
      Dom.element "div"
        |> Dom.appendChild
          ( inputField "enter any number"
            |> Dom.addClass "my-3"
            |> Dom.addInputHandlerWithParser (ParseFloat, String.toFloat)
          )

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

    contextClass maybeInt =
      case maybeInt of
        Nothing -> "secondary"
        Just _ -> "success"

    groupedFields =
      [ ( intInput
        , ""
        )
      , ( labelText "Parsing with String.toInt:"
        , "dark"
        )
      , ( outputText (value.int |> Debug.toString)
        , contextClass value.int
        )
      , ( floatInput
        , ""
        )
      , ( labelText "Parsing with String.toFloat:"
        , "dark"
        )
      , ( outputText (value.float |> Debug.toString)
        , contextClass value.float
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
