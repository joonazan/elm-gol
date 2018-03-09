module Main exposing (..)

import Collage.Render
import Collage exposing (..)
import Set exposing (Set)
import Color


main =
    tyhja
        |> laitaRuutuun ( 0, 0 )
        |> laitaRuutuun ( 3, 2 )
        |> piirraRuudukko 10
        |> Collage.Render.svg


type alias Piste =
    ( Int, Int )


type alias Ruudukko =
    Set Piste


tyhja : Ruudukko
tyhja =
    Set.empty


laitaRuutuun : Piste -> Ruudukko -> Ruudukko
laitaRuutuun paikka =
    Set.insert paikka


poistaRuudusta : Piste -> Ruudukko -> Ruudukko
poistaRuudusta paikka =
    Set.remove paikka


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
