declare option output:indent "yes";
(:5:)
(: for $a in doc("db/bib/bib.xml")//bib/book/author/last :)
(: return $a :)

(:6:)
(: for $book in doc("db/bib/bib.xml")//bib/book
for $author in $book/author, $title in $book/title
return <ksiazka>{$author, $title}</ksiazka> :)

(:7:)
(: for $book in doc("db/bib/bib.xml")//bib/book
for $author in $book/author, $title in $book/title
let $fullname := <autor>{concat($author/last, $author/first)}</autor>
return <ksiazka>{$fullname, $title}</ksiazka> :)

(:8:)
(: for $book in doc("db/bib/bib.xml")//bib/book
for $author in $book/author, $title in $book/title
let $fullname := <autor>{concat($author/last, " ", $author/first)}</autor>
return <ksiazka>{$fullname, $title}</ksiazka> :)

(:9:)
(: <wynik>
{
  for $book in doc("db/bib/bib.xml")//bib/book
  for $author in $book/author, $title in $book/title
  return <ksiazka>{$author, $title}</ksiazka>
}
</wynik> :)

(:10:)
(: <imiona>
{
  for $book in doc("db/bib/bib.xml")//bib/book
  where $book/title = 'Data on the Web'
  for $author in $book/author
  return <imie>{$author/first/text()}</imie>
}
</imiona> :)

(:11:)
(: <DataOnTheWeb>
{
  doc("db/bib/bib.xml")//bib/book[title='Data on the Web']
}
</DataOnTheWeb> :)
(: <DataOnTheWeb>
{
  for $book in doc("db/bib/bib.xml")//bib/book
  where $book/title = 'Data on the Web'
  return $book
}
</DataOnTheWeb> :)

(:12:)
(: <Data>
{
  for $book in doc("db/bib/bib.xml")//bib/book
  where contains($book/title, 'Data')
  for $lastname in $book/author/last
  return <nazwisko>{$lastname/text()}</nazwisko>
}
</Data> :)

(:13:)
(: <Data>
{
  for $book in doc("db/bib/bib.xml")//bib/book
  where contains($book/title, 'Data')
  return (
    <title>{$book/title/text()}</title>,
    for $lastname in $book/author/last
    return <nazwisko>{$lastname/text()}</nazwisko>
  )
}
</Data> :)

(:14:)
(: for $book in doc("db/bib/bib.xml")//bib/book
where count($book/author) <= 2
return $book/title :)

(:15:)
(: for $book in doc("db/bib/bib.xml")//bib/book
return 
  <ksiazka>
    <title>{$book/title/text()}</title>
    <autorow>{count($book/author)}</autorow>
  </ksiazka>
:)

(:16:)
(: let $years := doc("db/bib/bib.xml")//bib/book/@year
return <przedzial>{min($years)} - {max($years)}</przedzial> :)

(:17:)
(: let $prices := doc("db/bib/bib.xml")//bib/book/price
return <różnica>{max($prices) - min($prices)}</różnica> :)

(:18:)
(: <najtańsze>
{
  let $prices := doc("db/bib/bib.xml")//bib/book/price
  for $book in doc("db/bib/bib.xml")//bib/book
  where $book/price = min($prices)
  return <najtańsza>{$book/title,$book/author}</najtańsza>
}
</najtańsze> :)

(:19:)
(: let $unique-authors := distinct-values(doc("db/bib/bib.xml")//bib/book/author/last)
for $lastname in $unique-authors
return
  <autor>
    <nazwisko>{$lastname}</nazwisko>
    {
      for $book in doc("db/bib/bib.xml")//bib/book
      where $book/author/last = $lastname
      return <tytul>{$book/title/text()}</tytul>
    }
  </autor> :)

(:20:)
(: for $title in collection("db/shakespeare")//PLAY/TITLE
return $title :)

(:21:)
(: for $play in collection("db/shakespeare")//PLAY
where some $line in $play//LINE satisfies contains($line, 'or not to be')
return $play/TITLE :)

(:22:)
<wynik>
{
  for $play in collection("db/shakespeare")//PLAY
  return 
    <sztuka tytul="{$play/TITLE}">
      <postaci>{count($play/PERSONAE/PGROUP/PERSONA) + count($play/PERSONAE/PERSONA)}</postaci>
      <aktow>{count($play/ACT)}</aktow>
      <scen>{count($play/ACT/SCENE)}</scen>
    </sztuka>
}
</wynik>