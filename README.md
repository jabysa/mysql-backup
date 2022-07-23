# mysql-backup
Super full smart backup of all databases mysql


Configuration and change path backup or ignore databases
``` bash
vi smart-backup.sh 
```

Start create full backup 
``` bash
sh smart-backup.sh 
```


For import use this command 
``` bash
for SQL in *.sql; do DB=${SQL/\.sql/}; echo importing $DB; mysql $DB -f -u root -p'yourPassword' < $SQL; done
```
