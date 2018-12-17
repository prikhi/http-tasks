# HTTP Tasks

This library includes some convenience functions for building HTTP requests as
Tasks instead of Cmds, including things like making GET requests & decoding JSON:

```elm
import Http
import Http.Tasks exposing (get, resolveString, resolveJson)
import Task exposing (Task)


type Msg
    = ReceiveData (Result Http.Error MyType)

type alias MyType =
    { fieldOne : String
    , fieldTwo : String
    }

decodeMyType =
    Decode.map MyType
        |> Decode.field "fieldOne" Decode.string
        |> Decode.field "fieldTwo" Decode.string


firstTask : Task Http.Error String
firstTask =
    get
        { url = "https://some.domains.api"
        , resolver = resolveString
        }

secondTask : String -> Task Http.Error MyType
secondTask somePath =
    get
        { url = "https://some/domains.api/" ++ somePath ++ "/"
        , resolver = resolveJson decodeMyType
        }

myCommand : Cmd Msg
myCommand =
    firstTask
        |> Task.andThen secondTask
        |> Task.attempt ReceiveData
```

## License

MIT, but exceptions possible.
