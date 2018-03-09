module Main exposing (..)

import Collage.Render
import Collage exposing (..)
import Set exposing (Set)
import Color


main =
    piirraRuudukko 10 tyhja
        |> Collage.Render.svg


type alias Piste =
    ( Int, Int )


type alias Ruudukko =
    Set Piste


tyhja : Ruudukko
tyhja =
    Set.empty


piirraRuudukko : Float -> Ruudukko -> Collage msg
piirraRuudukko mittakaava =
    Set.toList
        >> List.map
            (\( x, y ) ->
                shift ( mittakaava * toFloat x, mittakaava * toFloat y ) (elava mittakaava)
            )
        >> group


elava : Float -> Collage msg
elava mittakaava =
    square mittakaava
        |> filled (uniform Color.green)
