#CONFIGURATIONS
USER="root"
PASSWORD="yourpassword"
IGNORE_DATABASES="'INFORMATION_SCHEMA','PERFORMANCE_SCHEMA','mysql','data_analysis'"
DBS_CHARSET=utf8
COLLATE=utf8_unicode_ci
BK_PATH=/home/
#============================


DATE=`date +%F-%H-%M`
BK_PATH=${BK_PATH}${DATE}

#CHECK REQUIREDS
REQUIRED_PKG="tar"
CHECK=$(which $REQUIRED_PKG)
if [ -z $CHECK ]; then
  echo "";echo "!!!!!  No $REQUIRED_PKG. Install $REQUIRED_PKG and tryagin. !!!!!";echo "";exit 1;
fi

if [ -d $BK_PATH ]; then
  echo "";echo "!!!!!  Directory $BK_PATH EXISTS , please move or remove or rename and tryagin. !!!!!";echo "";exit 1;
else
  mkdir -p $BK_PATH
  echo "Directory $BK_PATH CREATED ...";echo ""
fi

#MAKE QUERY CREATE DATABASES
echo "MAKE QUERY CREATE DATABASES ...";echo ""
mysql -u$USER -p$PASSWORD -N -e"SELECT CONCAT(' CREATE DATABASE IF NOT EXISTS ',SCHEMA_NAME,' CHARACTER SET $DBS_CHARSET COLLATE  $COLLATE ; ') AS 'sql'
FROM \`INFORMATION_SCHEMA\`.\`schemata\` WHERE \`SCHEMA_NAME\` NOT IN ($IGNORE_DATABASES);" > $BK_PATH/1-databases.sql

#MAKE MYSQLDUMP DATABASES WITH VIEWS
echo "MAKE MYSQLDUMP DATABASES WITH VIEWS ...";echo ""
mysql -u$USER -p$PASSWORD -N -e"SET SESSION  group_concat_max_len = 999999999; SELECT CONCAT('echo ',TABLE_SCHEMA,' Starting backup just wating ...; mysqldump -u$USER -p\"$PASSWORD\"  --opt --routines --default-character-set=$DBS_CHARSET ',TABLE_SCHEMA,' ',GROUP_CONCAT(' --ignore-table=',\`TABLE_SCHEMA\`,'.',\`TABLE_NAME\` SEPARATOR ' '),' > $BK_PATH/',TABLE_SCHEMA,'.sql ; ') AS \`sql\` FROM \`INFORMATION_SCHEMA\`.\`TABLES\` WHERE \`TABLE_TYPE\` = 'VIEW' AND \`TABLE_SCHEMA\` NOT IN ($IGNORE_DATABASES) GROUP BY \`TABLE_SCHEMA\`;" > $BK_PATH/backupTemp.sql

#MAKE MYSQLDUMP DATABASES WITHOUT VIEWS
echo "MAKE MYSQLDUMP DATABASES WITHOUT VIEWS ...";echo ""
mysql -u$USER -p$PASSWORD -N -e"SELECT CONCAT('echo ',SCHEMA_NAME,' Starting backup just wating ...; mysqldump -u$USER -p\"$PASSWORD\"  --opt --routines --default-character-set=$DBS_CHARSET ',SCHEMA_NAME,' ',' > $BK_PATH/',SCHEMA_NAME,'.sql ; ') AS \`sql\` FROM \`INFORMATION_SCHEMA\`.\`schemata\` WHERE \`SCHEMA_NAME\` NOT IN (SELECT \`TABLE_SCHEMA\` FROM \`INFORMATION_SCHEMA\`.\`TABLES\` WHERE \`TABLE_TYPE\` = 'VIEW'  GROUP BY \`TABLE_SCHEMA\`) AND \`SCHEMA_NAME\` NOT IN ($IGNORE_DATABASES);" >> $BK_PATH/backupTemp.sql

#MAKE QUERY VIEWS
echo "MAKE MYSQLDUMP DATABASES WITHOUT VIEWS ...";echo ""
mysql -u$USER -p$PASSWORD -N -e"SET SESSION  group_concat_max_len = 999999999;select CONCAT('DROP TABLE IF EXISTS ', TABLE_SCHEMA, '.', TABLE_NAME, '; CREATE OR REPLACE VIEW ', TABLE_SCHEMA, '.', TABLE_NAME, ' AS ', VIEW_DEFINITION, '; ') table_name from information_schema.views" > $BK_PATH/views.sql

echo "";echo "";echo "This may take several minutes just wating ...";echo ""
sh $BK_PATH/backupTemp.sql
rm -rf $BK_PATH/backupTemp.sql

cd $BK_PATH && tar -zcvf ../full.tar.gz . && cd -
rm -rf $BK_PATH/*.sql
echo " Congratulations , Your full backup is here => $BK_PATH/full.tar.gz"
