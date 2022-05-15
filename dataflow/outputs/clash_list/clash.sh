source ../ENV.sh

rm out
# if needed:
# mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD -e "ALTER TABLE names DROP COLUMN name; ALTER TABLE names ADD COLUMN name VARCHAR(200); UPDATE names SET name = CONCAT_WS(' ',genhyb,genus,sphyb,species,ssptype,ssp,author);" akflora

#       ALA  PAF  WCSP  ACCS  FNA
#  ALA        1     2    3     4
#  PAF              5    6     7
#  WCSP                  8     9
#  ACCS                       10        
#  FNA

# 1
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @s1='ALA', @s2='PAF'; source clash.sql;" akflora >> out
# 2
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @s1='ALA', @s2='WCSP'; source clash.sql;" akflora >> out
# 3
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @s1='ALA', @s2='ACCS'; source clash.sql;" akflora >> out
# 4
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @s1='ALA', @s2='FNA'; source clash.sql;" akflora >> out
# 5
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @s1='PAF', @s2='WCSP'; source clash.sql;" akflora >> out
# 6
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @s1='PAF', @s2='ACCS'; source clash.sql;" akflora >> out
# 7
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @s1='PAF', @s2='FNA'; source clash.sql;" akflora >> out
# 8
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @s1='WCSP', @s2='ACCS'; source clash.sql;" akflora >> out
# 9
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @s1='WCSP', @s2='FNA'; source clash.sql;" akflora >> out
# 10
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @s1='ACCS', @s2='FNA'; source clash.sql;" akflora >> out
