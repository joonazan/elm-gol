module Main exposing (..)

import Collage exposing (..)
import Collage.Events exposing (onClick)
import Collage.Layout exposing (..)
import Collage.Render
import Collage.Text
import Color
import Dict
import Html
import Set exposing (Set)


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
    näkyvätRuudut ruudukko
        |> List.map (\p -> piirräRuutu mittakaava p (Set.member p ruudukko))
        |> group


piirräRuutu : Float -> Piste -> Bool -> Collage Viesti
piirräRuutu mittakaava (( x, y ) as paikka) elossa =
    let
        ( väri, toiminto ) =
            if elossa then
                ( Color.green, Poista )
            else
                ( Color.black, Lisää )
    in
    square mittakaava
        |> filled (uniform väri)
        |> shift ( mittakaava * toFloat x, mittakaava * toFloat y )
        |> onClick (toiminto paikka)


näkyvätRuudut : Ruudukko -> List Piste
näkyvätRuudut ruudukko =
    let
        ( äksät, yyt ) =
            List.unzip (Set.toList ruudukko)

        vaihteluväli x =
            List.range
                ((List.minimum x |> Maybe.withDefault 0) - tyhjääNäytetään)
                ((List.maximum x |> Maybe.withDefault 0) + tyhjääNäytetään)

        -- montako tyhjää ruutua näytetään elävän alueen ympäriltä
        tyhjääNäytetään =
            5
    in
    karteesinenTulo (vaihteluväli äksät) (vaihteluväli yyt)


karteesinenTulo : List a -> List b -> List ( a, b )
karteesinenTulo ekat toiset =
    List.concatMap
        (\x -> List.map ((,) x) toiset)
        ekat
