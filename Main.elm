module Main exposing (..)

import Collage.Render
import Collage exposing (..)
import Set exposing (Set)
import Color


main =
    tyhjä
        |> laitaRuutuun ( 0, 0 )
        |> laitaRuutuun ( 3, 2 )
        |> piirräRuudukko 10
        |> Collage.Render.svg


type alias Piste =
    ( Int, Int )


type alias Ruudukko =
    Set Piste


tyhjä : Ruudukko
tyhjä =
    Set.empty


laitaRuutuun : Piste -> Ruudukko -> Ruudukko
laitaRuutuun paikka =
    Set.insert paikka


poistaRuudusta : Piste -> Ruudukko -> Ruudukko
poistaRuudusta paikka =
    Set.remove paikka


piirräRuudukko : Float -> Ruudukko -> Collage msg
piirräRuudukko mittakaava ruudukko =
    let
        elävät =
            Set.toList ruudukko

        ( äksät, yyt ) =
            List.unzip elävät

        vaihteluväli x =
            List.range
                ((List.minimum x |> Maybe.withDefault 0) - tyhjääNäytetään)
                ((List.maximum x |> Maybe.withDefault 0) + tyhjääNäytetään)

        -- montako tyhjää ruutua näytetään elävän alueen ympäriltä
        tyhjääNäytetään =
            5
    in
        -- leksikografinen järjestys, jotta elävät olisivat
        -- samassa järjestyksessä kuin nämä
        vaihteluväli äksät
            |> List.concatMap (\x -> List.map ((,) x) (vaihteluväli yyt))
            |> List.foldl
                (\paikka ( elävät, ulos ) ->
                    let
                        kuollut =
                            ( elävät, väriksi Color.black )

                        väriksi väri =
                            piirräRuutu mittakaava paikka väri :: ulos
                    in
                        case elävät of
                            eka :: loput ->
                                if eka == paikka then
                                    ( loput, väriksi Color.green )
                                else
                                    kuollut

                            [] ->
                                kuollut
                )
                ( elävät, [] )
            |> Tuple.second
            |> group


piirräRuutu : Float -> Piste -> Color.Color -> Collage msg
piirräRuutu mittakaava ( x, y ) väri =
    square mittakaava
        |> filled (uniform väri)
        |> shift ( mittakaava * toFloat x, mittakaava * toFloat y )
