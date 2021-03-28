#!/bin/bash

##
## Das RKI bietet unter https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/nCoV.html folgende
## Daten zum Download an (Stand Samstag, 24.10.2020, 08:00)
##
#
# Gesamtübersicht der pro Tag ans RKI übermittelten Fälle, Todesfälle und 7-Tages-Inzidenzen nach Bundesland und Landkreis
# https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Fallzahlen_Kum_Tab.html
# Excel-Datei: https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Fallzahlen_Kum_Tab.xlsx?__blob=publicationFile
#
# Tabellen zu Testzahlen, Testkapazitäten und Probenrückstau pro Woche (21.10.2020) (xlsx, 22 KB, Datei ist nicht barrierefrei)
# https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Testzahlen-gesamt.xlsx?__blob=publicationFile
#
# Todesfälle nach Sterbedatum (22.10.2020) (xlsx, 3 KB, Datei ist nicht barrierefrei)
# https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/COVID-19_Todesfaelle.xlsx?__blob=publicationFile
#
# Aktuelle Ergebnisse des Nowcasting und der R-Schätzung
# https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/Nowcasting.html
# Excel-Datei: https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/Nowcasting_Zahlen.xlsx?__blob=publicationFile
# CSV-Datei: https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/Nowcasting_Zahlen_csv.csv?__blob=publicationFile
#
# COVID-19-Fälle nach Altersgruppe und Meldewoche
# https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Altersverteilung.html
# Excel-Datein https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Altersverteilung.xlsx;jsessionid=BBA0E867314E7133E733D3E5D3459A48.internet082?__blob=publicationFile


# SurvStat - individuelle Abfrage von Meldedaten
# https://survstat.rki.de/Content/Query/Create.aspx


# Zeitstempel im Format 2020-10-24--07-50-05
export NOW=`/usr/bin/date "+%Y-%m-%d--%H-%M-%S"`

/usr/bin/mkdir -p data

# Ich habe dummerweise zwei wget-Versionen auf meinem Rechner
# Version 0.4.3 /rki-data/sdb1/home/obama/bin/node-v10.15.1-linux-x64/bin/wget 
# GNU Wget 1.20.3 built on linux-gnu /usr/bin/wget

# Excel-Datei mit den kumulierten Fallzahlen:
/usr/bin/wget https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Fallzahlen_Kum_Tab.xlsx?__blob=publicationFile --append-output ./rki-data/wget-rki.log --output-document ./rki-data/RKI-Fallzahlen_Kum_Tab-${NOW}.xlsx

# Excel-Datei mit den Todesfällen pro Kalenderwoche:
/usr/bin/wget https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/COVID-19_Todesfaelle.xlsx?__blob=publicationFile --append-output ./rki-data/wget-rki.log --output-document ./rki-data/RKI-COVID-19_Todesfaelle-${NOW}.xlsx

# Excel-Datei mit Nowcasting und R-Schätzung
/usr/bin/wget https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/Nowcasting_Zahlen.xlsx?__blob=publicationFile --append-output ./rki-data/wget-rki.log --output-document ./rki-data/RKI-Nowcasting_Zahlen-${NOW}.xlsx

# Excel-Datei mit Testzahlen
/usr/bin/wget https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Testzahlen-gesamt.xlsx?__blob=publicationFile --append-output ./rki-data/wget-rki.log --output-document ./rki-data/RKI-Testzahlen-gesamt-${NOW}.xlsx

# Excel-Datei mit Altersverteilung
/usr/bin/wget 'https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Altersverteilung.xlsx;jsessionid=BBA0E867314E7133E733D3E5D3459A48.internet082?__blob=publicationFile' --append-output ./rki-data/wget-rki.log --output-document ./rki-data/RKI-Altersverteilung-${NOW}.xlsx


for f in ./rki-data/*${NOW}.xlsx ; do
    echo "downloaded xlsx file ${f}"
    /usr/bin/xlsx2csv --all --delimiter ";" ${f} ${f}.csv
done


# curl 'https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/Covid19_RKI_Sums/FeatureServer/0/query?f=json&where=(Meldedatum%3Etimestamp%20%272020-03-01%2022%3A59%3A59%27%20AND%20Meldedatum%20NOT%20BETWEEN%20timestamp%20%272020-11-09%2023%3A00%3A00%27%20AND%20timestamp%20%272020-11-10%2022%3A59%3A59%27)%20AND%20(IdLandkreis%3D%2708111%27)&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=ObjectId%2CSummeFall%2CMeldedatum&orderByFields=Meldedatum%20asc&resultOffset=0&resultRecordCount=32000&resultType=standard&cacheHint=true' \
#   -H 'authority: services7.arcgis.com' \
#   -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36' \
#   -H 'accept: */*' \
#   -H 'origin: https://npgeo-de.maps.arcgis.com' \
#   -H 'sec-fetch-site: same-site' \
#   -H 'sec-fetch-mode: cors' \
#   -H 'sec-fetch-dest: empty' \
#   -H 'referer: https://npgeo-de.maps.arcgis.com/apps/opsdashboard/index.html' \
#   -H 'accept-language: en-US,en;q=0.9' \
#   --compressed

#   curl 'https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_COVID19/FeatureServer/0/query?f=json&where=IdLandkreis%3D%2708111%27&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&resultOffset=0&resultRecordCount=1&resultType=standard&cacheHint=true' \
#   -H 'authority: services7.arcgis.com' \
#   -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36' \
#   -H 'accept: */*' \
#   -H 'origin: https://npgeo-de.maps.arcgis.com' \
#   -H 'sec-fetch-site: same-site' \
#   -H 'sec-fetch-mode: cors' \
#   -H 'sec-fetch-dest: empty' \
#   -H 'referer: https://npgeo-de.maps.arcgis.com/apps/opsdashboard/index.html' \
#   -H 'accept-language: en-US,en;q=0.9' \
#   --compressed