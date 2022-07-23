# mysql-backup
Super full smart backup of all databases mysql


For import use this command 
``` bash
for SQL in *.sql; do DB=${SQL/\.sql/}; echo importing $DB; mysql $DB -f -u root -p'yourPassword' < $SQL; done
```
