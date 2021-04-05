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


# Diese Datei:
export THIS_FILE=$(/usr/bin/readlink --canonicalize ${0})
# Das Verzeichnis, in dem diese Datei liegt:
export THIS_DIR=$(/usr/bin/dirname ${THIS_FILE})
# Das Verzeichnis über dem Verzeichnis, in dem diese Datei liegt:
export THIS_PARENT_DIR=$(/usr/bin/readlink --canonicalize ${THIS_DIR}/..)
# Zeitstempel im Format 2020-10-24--07-50-05:
export NOW=$(/usr/bin/date "+%Y-%m-%d--%H-%M-%S")
# Das Verzeichnis, in dem die Excel-DAtein des RKI gepsichert werden:
export RKI_DATA_DIR=${THIS_DIR}/rki-data

# Das brauchen wir nur zum Testen:
echo "THIS_FILE       ${THIS_FILE}"
echo "THIS_DIR        ${THIS_DIR}"
echo "THIS_PARENT_DIR ${THIS_PARENT_DIR}"
echo "RKI_DATA_DIR    ${RKI_DATA_DIR}"
echo "NOW             ${NOW}"

# Damit stellen wir sicher, dass das Verzeichnis auch wirklich existiert:
/usr/bin/mkdir -p ${RKI_DATA_DIR}

# Excel-Datei mit den kumulierten Fallzahlen:
/usr/bin/wget https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Fallzahlen_Kum_Tab.xlsx?__blob=publicationFile --append-output ${RKI_DATA_DIR}/wget-rki.log --output-document ${RKI_DATA_DIR}/RKI-Fallzahlen_Kum_Tab.xlsx

# Excel-Datei mit den Todesfällen pro Kalenderwoche:
/usr/bin/wget https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/COVID-19_Todesfaelle.xlsx?__blob=publicationFile --append-output ${RKI_DATA_DIR}/wget-rki.log --output-document ${RKI_DATA_DIR}/RKI-COVID-19_Todesfaelle.xlsx

# Excel-Datei mit Nowcasting und R-Schätzung
/usr/bin/wget https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/Nowcasting_Zahlen.xlsx?__blob=publicationFile --append-output ${RKI_DATA_DIR}/wget-rki.log --output-document ${RKI_DATA_DIR}/RKI-Nowcasting_Zahlen.xlsx

# Excel-Datei mit Testzahlen
/usr/bin/wget https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Testzahlen-gesamt.xlsx?__blob=publicationFile --append-output ${RKI_DATA_DIR}/wget-rki.log --output-document ${RKI_DATA_DIR}/RKI-Testzahlen-gesamt.xlsx

# Excel-Datei mit Altersverteilung
/usr/bin/wget 'https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Altersverteilung.xlsx;jsessionid=BBA0E867314E7133E733D3E5D3459A48.internet082?__blob=publicationFile' --append-output ${RKI_DATA_DIR}/wget-rki.log --output-document ${RKI_DATA_DIR}/RKI-Altersverteilung.xlsx


# Die Zeitreihen des DIVI-Intensivregisters gibt es hier
/usr/bin/wget https://diviexchange.blob.core.windows.net/%24web/bundesland-zeitreihe.csv --append-output ./rki-data/wget-rki.log --output-document ./rki-data/bundesland-zeitreihe.csv


cd ${THIS_DIR}

/usr/bin/git commit ${RKI_DATA_DIR}/*.xlsx -m"${0}: add data automatically downloaded at ${NOW}"

for f in ${RKI_DATA_DIR}/RKI*.xlsx ; do
    echo "extracting csv files from downloaded xlsx file ${f}"
    /usr/bin/xlsx2csv --all --delimiter ";" --dateformat %Y-%m-%d ${f} ${RKI_DATA_DIR}/$(/usr/bin/basename ${f} .xlsx)-csv
done

/usr/bin/git status -u


export THEN=$(/usr/bin/date "+%Y-%m-%d--%H-%M-%S")

echo "Script Start ${NOW}"
echo "Script End   ${THEN}"

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