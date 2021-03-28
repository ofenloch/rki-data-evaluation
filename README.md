

Daily download of RKI Excel file via cron:

    # every day at 13:35 download Corona data from RKI
    35 13  *   *   *     cd /data/sdb1/home/ofenloch/workspaces/COVID19/rki-eval/ && /data/sdb1/home/ofenloch/workspaces/COVID19/rki-eval/getRKIData.sh 2>&1 | tee -a /data/sdb1/home/ofenloch/workspaces/COVID19/rki-eval/getRKIData.sh.cron.log


The files are copied into this directory with

```bash
ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation/rki-data$ for f in ~/workspaces/COVID19/rki-eval/rki-data/*2021-01-30--13-35-01*.xlsx ; do /bin/cp -pvf ${f} $(basename ${f} -2021-01-30--13-35-01.xlsx).xlsx ; done
'/home/ofenloch/workspaces/COVID19/rki-eval/rki-data/RKI-Altersverteilung-2021-01-30--13-35-01.xlsx' -> 'RKI-Altersverteilung.xlsx'
'/home/ofenloch/workspaces/COVID19/rki-eval/rki-data/RKI-COVID-19_Todesfaelle-2021-01-30--13-35-01.xlsx' -> 'RKI-COVID-19_Todesfaelle.xlsx'
'/home/ofenloch/workspaces/COVID19/rki-eval/rki-data/RKI-Fallzahlen_Kum_Tab-2021-01-30--13-35-01.xlsx' -> 'RKI-Fallzahlen_Kum_Tab.xlsx'
'/home/ofenloch/workspaces/COVID19/rki-eval/rki-data/RKI-Nowcasting_Zahlen-2021-01-30--13-35-01.xlsx' -> 'RKI-Nowcasting_Zahlen.xlsx'
'/home/ofenloch/workspaces/COVID19/rki-eval/rki-data/RKI-Testzahlen-gesamt-2021-01-30--13-35-01.xlsx' -> 'RKI-Testzahlen-gesamt.xlsx'
ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation/rki-data$ 
```



The data in the Excel files is extracted into CSV file by

    xlsx2csv --all --delimiter ";" FileName.xlsx FileName-csv

```bash
ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation/rki-data$ for f in *.xlsx ; do xlsx2csv --all --delimiter ";" ${f} $(basename ${f} .xlsx)-csv ; done 
ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation/rki-data$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   RKI-Fallzahlen_Kum_Tab-csv/7Tage_LK.csv
        modified:   RKI-Fallzahlen_Kum_Tab-csv/BL_7-Tage-Fallzahlen.csv
        modified:   RKI-Fallzahlen_Kum_Tab-csv/BL_7-Tage-Inzidenz.csv
        modified:   "RKI-Fallzahlen_Kum_Tab-csv/F\303\244lle-Todesf\303\244lle-gesamt.csv"
        modified:   RKI-Fallzahlen_Kum_Tab-csv/Tageswerte berechnet.csv
        modified:   RKI-Fallzahlen_Kum_Tab.xlsx
        modified:   "RKI-Nowcasting_Zahlen-csv/Erl\303\244uterung.csv"
        modified:   RKI-Nowcasting_Zahlen-csv/Nowcast_R.csv
        modified:   RKI-Nowcasting_Zahlen.xlsx

no changes added to commit (use "git add" and/or "git commit -a")
ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation/rki-data$ 
```


The sheet names change sometimes. Sometimes new sheets are added.