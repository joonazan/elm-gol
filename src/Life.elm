module Life exposing (..)

{-| Conways Game of Life on alun perin ruutupaperilla pelattu simulaatio,
jossa pienet aloituskuviot voivat tuottaa yllättävän monimutkaista "elämää".

Väritettyjä ruutuja kutsutaan eläviksi ja tyhjiä kuolleiksi. Ruudun naapurien
lukumäärä kertoo kuinka moni kahdeksasta ympäröivästä ruudusta on elossa.

Seuraava kuva piirretään näin:

  - Jos ruutu ei ole elossa ja sillä on tasan kolme naapuria, se herää henkiin.
  - Jos ruutu on jo elossa ja sillä on kaksi tai kolme elävää naapuria
    , se pysyy elossa.
  - Muutoin ruutu kuolee tai pysyy kuolleena.

Teemme *Lifeä* simuloivan ohjelman, jossa käyttäjä voi herättää henkiin tai tappaa
soluja mielensä mukaan ja viedä simulaatiota eteenpäin painamalla nappia.

![kuva lopullisesta](https://i.imgur.com/dhIOxhQ.png)


# 0. Maailman esittäminen

@docs Piste

@docs Ruudukko

Set vastaa matematiikan joukkoa. Settiin voi tallentaa järjestämättömän joukon uniikkeja arvoja.
Se on tähän oikea valinta, sillä ruutujen järjestyksellä ei ole väliä,
emmekä halua tallentaa samaa ruutua moneen kertaan.

Vaihtoehtoisesti voisi rakentaa taulukon,
jossa on jokaiselle ruudulle tieto siitä onko se elossa.


# 1. Ruudukko näkyviin

On hyvä saada ruudukko näkyviin, jotta ei joudu työskentelemään sokkona.
Laitetaan siihen myös eläviä soluja ettei se olisi vain tyhjää mustuutta.

    main =
        tyhja
            |> laitaRuutuun ( 0, 0 )
            |> laitaRuutuun ( 3, 2 )
            |> piirraRuudukko
            |> Collage.Render.svg

Kun olet määritellyt kaikki puuttuvat funktiot (lisätietoja alempana),
lopputuloksen pitäisi näyttää suunnilleen tältä:

![kuva piirtotestistä](https://i.imgur.com/LyFj0bt.png)

@docs tyhja, laitaRuutuun
@docs piirraRuudukko

Tätä funktiota koodatessa kannattaa hyödyntää funktioita `piirraRuutu` ja `nakyvatRuudut`.

`piirraRuutu` ja `piirraRuudukko` referensoivat paluuarvossaan tyyppiä `Viesti`,
jota emme vielä tässä vaiheessa määrittele. Tämän voi korjata esim. muuttamalla
funktioiden paluuarvoksi `Collage a`.

@docs piirraRuutu, mittakaava

Funktio `piirraRuutu` saa argumenttina tiedon siitä, onko ruutu elossa. Mistä se tieto
ruudun elossa olemisesta saadaan, kun sitä ei ole erikseen talletettu mihinkään?

**Vinkki:** Edellä mainittiin, että `Set Ruudukko` sisältää elävien ruutujen koordinaatit.
`Set`-moduulin funktio `member` kertoo, onko jokin tietty arvo annetussa setissä.

@docs nakyvatRuudut

Voit määritellä alkuun näkyväksi alueeksi 20 x 20 ruutua, joiden koordinaatit vaihtelevat välillä `[0,20)`.
Kopioi silloin koodiisi alla oleva toteutus.

    nakyvatRuudut _ =
        karteesinenTulo (List.range 0 20) (List.range 0 20)

Kun elossa olevien ruutujen ympärille syntyy uusia soluja, osa niistä voi joutua näkymän
ulkopuolelle. Siksi esimerkkiratkaisussa näkyvyysaluetta säädetään niin,
että siihen mahtuvat kaikki elävät solut sekä sopivasti tilaa niiden ympärille. Voit
myöhemmin katsoa toteutuksen ohjelmalistauksesta ja lisätä sen omaan ohjelmaasi.

@docs karteesinenTulo

Karteesisen tulon toteuttamiseen List.concatMap on näppärä. **Tee karteesisesta tulosta
havainnollistava selostus.**


# 2. Solujen lisääminen hiirellä

@docs Viesti


## Kuvasta interaktiiviseen ohjelmaan

@docs main

    main =
        Html.beginnerProgram
            { model = tyhja
            , view = view
            , update = update
            }

Aloitetaan tekemällä ohjelmastamme versio, joka toimii tuttun tapaan,
mutta käyttää beginnerProgramia.

Joudumme määrittelemään funktiot `view` ja `update`.
Tehdään niille mahdollisimman yksinkertaiset toteutukset.

@docs view

    view ruudukko =
        piirraRuudukko ruudukko
            |> Collage.Render.svg

@docs update

    update viesti ruudukko =
        ruudukko

Nyt ohjelmasi pitäisi piirtää tyhjä ruudukko. Klikkausten käsittelyn toteutamme seuraavaksi.


## Viestien lähettäminen

Ruutujen pitäisi laukaista viesti kun niitä klikataan.
Tämä onnistuu Collage.Events:n onClick-funktiolla.

Muuta funktiota `piirraRuutu` niin, että elävä ruutu
lähettää viestin `Poista` klikatessa ja kuollut viestin `Lisää`.


## Viestien käsitteleminen

Tällä hetkellä `update` kuittaa kaikki viestit palauttamalla ruudukon muuttamattomana.
Laita se lisäämään ja tappamaan soluja viestien saapuessa!

Nyt tarvitset funktion `lisääRuutuun` vastaoperaation.

@docs poistaRuudusta

Lisää `update`-funktioon
oma haaransa myös viestille Simuloi. Sen ei tässä vaiheessa tarvitse tehdä mitään,
riittää, että se palauttaa muuttumattoman ruudukon.


# 3. Simulointi

Muuta `view` niin, että se piirtää myös napin funktiolla `askelNappi`.
Ruudukon ja napin saa aseteltua vierekkäin Collage.Layout-kirjaston funktioilla.

@docs askelNappi

@docs simuloi

Päivitä tässä vaiheessa `update`-funktiota niin, että viesti Simuloi
käynnistää funktion `simuloi`.


## Naapurien laskeminen

Naapurisolut ovat ne, joiden x-, y- tai molemmat koordinaatit eroavat yhdellä
tarkasteltavasta ruudusta (x, y), eli esim. `(x+1, y)` tai `(x+1, y+1)`.

Jos esimerkin lailla avaruutesi on ääretön kaikkiin suuntiin, kaikkia ruutuja
ei voi käydä läpi. Sen sijaan voit käydä läpi kaikki elossa olevat solut.
Kun määrität yksi kerrallaan jokaisen elossa olevan solun ympärillä sijaitsevien
kahdeksan ruudun koordinaatit ja lisäät niistä jokaiselle yhden naapurin
lisää, sinulla on koossa kaikki pelin sääntöjen soveltamiseen vaadittu tieto.

Dict on näppärä tietorakenne koordinaattien ja niiden naapurien
määrän tallettamiseen.

Dict on Setin kaltainen tietorakenne, jossa alkioiden
järjestyksellä ei ole väliä. Dict sisältää avain-arvo-pareja. Meidän
ohjelmassamme avaimet ovat koordinaatteja (x, y) ja arvot naapurien
lukumääriä. Dict’istä voidaan avaimen perusteella hakea sitä vastaava arvo.


## Elävien määrittäminen

Kun naapurien laskennan tulokset, eli Dictin, joka sisältää pareja
koordinaatti - naapurien määrä, suodattaa funktiolla `rule`,
jäljelle jäävät pelin seuraavan sukupolven elävät solut.

@docs rule


# Testaa tekelettäsi!

Alla on aloituskuvioita, jotka tuottavat mielenkiintoisia tuloksia.

    LISÄÄ KUVIA


# Jatkokehitystä

  - Kokeile muita soluautomaattisääntöjä.
    Voit vaikka tehdä käyttäliittymän jolla voi suunnille oman säännön
    ruutuja rastittamalla.

  - Laita simulaatio pyörimään ajastetusti että käyttäjän ei tarvitse klikkailla
    toistuvasti askelnappia.

-}

import Collage exposing (..)
import Collage.Events exposing (onClick)
import Collage.Layout exposing (..)
import Collage.Render
import Collage.Text
import Color
import Dict
import Html
import Set exposing (Set)


{-| -}
main : Program Never Ruudukko Viesti
main =
    Html.beginnerProgram
        { model = tyhja
        , view = view
        , update = update
        }


{-| Määritää koko ohjelman ulkonäön.
-}
view : Ruudukko -> Html.Html Viesti
view ruudukko =
    [ askelNappi, piirraRuudukko ruudukko ]
        |> List.map (align left)
        |> vertical
        |> Collage.Render.svg


{-| Piirtää napin, jossa lukee "Askel". Klikattaessa nappi laukaisee viestin `Simuloi`.
-}
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


{-| Kuvaa asioita mitä käyttäjä voi tehdä.
-}
type Viesti
    = Lisää Piste
    | Poista Piste
    | Simuloi


{-| -}
update : Viesti -> Ruudukko -> Ruudukko
update viesti =
    case viesti of
        Lisää paikka ->
            laitaRuutuun paikka

        Poista paikka ->
            poistaRuudusta paikka

        Simuloi ->
            simuloi


{-| Simuloi ruudukkoa yhden sukupolven Life-pelin sääntöjen mukaan.
-}
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
                    rule neighbors (Set.member pos ruudukko)
                )
            |> Dict.keys
            |> Set.fromList


{-| Soluautomaattisääntö.
Saa naapureiden määrän ja kertoo onko solu yhä elossa seuraavassa sukupolvessa.
-}
rule : Int -> Bool -> Bool
rule neighbors wasAlive =
    neighbors == 3 || neighbors == 2 && wasAlive


{-| Ruudun yksiselitteisesti määrittävä kokonaislukukoordinaatti.
-}
type alias Piste =
    ( Int, Int )


{-| Sisältää elävien ruutujen koordinaatit.
-}
type alias Ruudukko =
    Set Piste


{-| Palauttaa ruudukon, jossa ei ole yhtään elävää solua.
-}
tyhja : Ruudukko
tyhja =
    Set.empty


{-| Herättää henkiin solun koordinaattien osoittamassa paikkassa.
-}
laitaRuutuun : Piste -> Ruudukko -> Ruudukko
laitaRuutuun paikka =
    Set.insert paikka


{-| Tappaa solun koordinaattien osoittamassa paikassa.
-}
poistaRuudusta : Piste -> Ruudukko -> Ruudukko
poistaRuudusta paikka =
    Set.remove paikka


{-| solun leveys pikseleinä
-}
mittakaava : Float
mittakaava =
    10


{-| Palauttaa kuvan ruudukosta.
-}
piirraRuudukko : Ruudukko -> Collage Viesti
piirraRuudukko ruudukko =
    nakyvatRuudut ruudukko
        |> List.map (\p -> piirraRuutu p (Set.member p ruudukko))
        |> group


{-| Piirtää yhden solun. Ensimmäinen argumentti kertoo solun paikan.
Toinen kertoo onko se elossa. Jos ruutu on elossa, se piirretään vihreänä, jos taas ei, mustana.
-}
piirraRuutu : Piste -> Bool -> Collage Viesti
piirraRuutu (( x, y ) as paikka) elossa =
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


{-| Palauttaa listan kaikista ruudulle piirrettävistä pisteistä,
riippumatta siitä, ovatko ne eläviä vai kuolleita.
-}
nakyvatRuudut : Ruudukko -> List Piste
nakyvatRuudut ruudukko =
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


{-| Kahden listan karteesinen tulo on lista kaikista mahdollisista listojen alkioiden yhdistelmistä.

    karteesinenTulo [1, 2] ['a', 'b', 'c']
    --> [(1, 'a'), (1, 'b'), (1, 'c'), (2, 'a'), (2, 'b'), (2, 'c')]

-}
karteesinenTulo : List a -> List b -> List ( a, b )
karteesinenTulo ekat toiset =
    List.concatMap
        (\x -> List.map ((,) x) toiset)
        ekat
