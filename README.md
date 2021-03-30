# IPAW2021-ORPE for Data Cleaning (Provenance) Model - DCM

Execute provenance harvester:
```
python provenance_harvester.py <openrefine_projectfile>
```
This will produce an sqlite db file

After we harvest the openreifne project artifacts, execute sqlite query report using
```
./report_query.sh ipaw_2021_demo.db <project dbfile>
```
This will produce queries result fromt the DCM
