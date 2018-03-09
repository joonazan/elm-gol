module Main exposing (..)

import Html
import Collage.Render
import Collage.Events exposing (onClick)
import Collage exposing (..)
import Set exposing (Set)
import Color


main : Program Never Ruudukko Viesti
main =
    Html.beginnerProgram
        { model =
            tyhjä
                |> laitaRuutuun ( 0, 0 )
                |> laitaRuutuun ( 3, 2 )
        , view =
            piirräRuudukko 10
                >> Collage.Render.svg
        , update = update
        }


type Viesti
    = Lisää Piste
    | Poista Piste


update : Viesti -> Ruudukko -> Ruudukko
update viesti =
    case viesti of
        Lisää paikka ->
            laitaRuutuun paikka

        Poista paikka ->
            poistaRuudusta paikka


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


piirräRuudukko : Float -> Ruudukko -> Collage Viesti
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
                            ( elävät, piirrä Color.black Lisää )

                        piirrä väri toiminto =
                            (piirräRuutu mittakaava paikka väri
                                |> onClick (toiminto paikka)
                            )
                                :: ulos
                    in
                        case elävät of
                            eka :: loput ->
                                if eka == paikka then
                                    ( loput
                                    , piirrä Color.green Poista
                                    )
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
