module Http.Tasks exposing
    ( get, post
    , resolveString, resolveJson, resolveWhatever, customResolver
    )

{-| Convenience functions for working with HTTP requests as Tasks.


# Requests

@docs get, post


# Resolvers

@docs resolveString, resolveJson, resolveWhatever, customResolver

-}

import Http exposing (Body, Error(..), Resolver, Response(..), emptyBody)
import Json.Decode as Decode exposing (Decoder)
import Task exposing (Task)


{-| Create a `GET` request.

You can use functions like [`resolveString`](#resolveString) and
[`resolveJson`](#resolveJson) to interpret the response in different ways.

-}
get : { url : String, resolver : Resolver x a } -> Task x a
get { url, resolver } =
    Http.task
        { method = "GET"
        , headers = []
        , url = url
        , body = emptyBody
        , resolver = resolver
        , timeout = Nothing
        }


{-| Create a `POST` request.
-}
post : { url : String, resolver : Resolver x a, body : Body } -> Task x a
post { url, resolver, body } =
    Http.task
        { method = "POST"
        , headers = []
        , url = url
        , body = body
        , resolver = resolver
        , timeout = Nothing
        }


{-| Expect the response body to be a `String`.
-}
resolveString : Resolver Error String
resolveString =
    Http.stringResolver (resolve Ok)


{-| Expect the response body to be JSON. Returns a `BadBody` error when JSON decoding fails.
-}
resolveJson : Decoder a -> Resolver Error a
resolveJson decoder =
    Http.stringResolver <|
        resolve <|
            Result.mapError Decode.errorToString
                << Decode.decodeString decoder


{-| Expect the response body to be anything, and the ignore it.
-}
resolveWhatever : Resolver Error ()
resolveWhatever =
    Http.stringResolver <| resolve <| always <| Ok ()


{-| Use your own body parsing function to build a resolver.
-}
customResolver : (String -> Result String a) -> Resolver Error a
customResolver parser =
    Http.stringResolver (resolve parser)


resolve : (body -> Result String a) -> Response body -> Result Error a
resolve bodyParser response =
    case response of
        BadUrl_ url ->
            Err (BadUrl url)

        Timeout_ ->
            Err Timeout

        NetworkError_ ->
            Err NetworkError

        BadStatus_ metadata _ ->
            Err (BadStatus metadata.statusCode)

        GoodStatus_ _ body ->
            Result.mapError BadBody (bodyParser body)
