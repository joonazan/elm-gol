module Main exposing (..)

import Html
import Collage.Render
import Collage.Layout exposing (..)
import Collage.Text
import Collage.Events exposing (onClick)
import Collage exposing (..)
import Set exposing (Set)
import Dict
import Color


main : Program Never Ruudukko Viesti
main =
    Html.beginnerProgram
        { model =
            tyhjä
                |> laitaRuutuun ( 0, 0 )
                |> laitaRuutuun ( 3, 2 )
        , view = view
        , update = update
        }


view : Ruudukko -> Html.Html Viesti
view ruudukko =
    [ askelNappi, piirräRuudukko 10 ruudukko ]
        |> List.map (align left)
        |> vertical
        |> Collage.Render.svg


askelNappi : Collage Viesti
askelNappi =
    let
        teksti =
            Collage.Text.fromString "Askel"
                |> rendered

        nappi =
            filled (uniform Color.yellow) (rectangle 100 29)
    in
        group [ teksti, nappi ]
            |> onClick Simuloi


type Viesti
    = Lisää Piste
    | Poista Piste
    | Simuloi


update : Viesti -> Ruudukko -> Ruudukko
update viesti =
    case viesti of
        Lisää paikka ->
            laitaRuutuun paikka

        Poista paikka ->
            poistaRuudusta paikka

        Simuloi ->
            simuloi


simuloi : Ruudukko -> Ruudukko
simuloi ruudukko =
    let
        increment pos dict =
            Dict.update pos
                (Maybe.map ((+) 1)
                    >> Maybe.withDefault 1
                    >> Just
                )
                dict
    in
        Set.toList ruudukko
            |> List.foldl
                (\( x, y ) ->
                    increment ( x + 1, y )
                        >> increment ( x - 1, y )
                        >> increment ( x, y + 1 )
                        >> increment ( x, y - 1 )
                        >> increment ( x + 1, y + 1 )
                        >> increment ( x + 1, y - 1 )
                        >> increment ( x - 1, y + 1 )
                        >> increment ( x - 1, y - 1 )
                )
                Dict.empty
            |> Dict.filter
                (\pos neighbors ->
                    neighbors == 3 || neighbors == 2 && Set.member pos ruudukko
                )
            |> Dict.keys
            |> Set.fromList


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
