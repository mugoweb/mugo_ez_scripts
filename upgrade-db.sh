#!/bin/bash

# Script to update the db from an eZ Publish instance
# 
# ./upgrade.sh <DB name> <Site access>
# 
# or
# 
# ./upgrade.sh
#
# TODO:
#   * Make it smarter and get the db from the site access
#   * Allow to skip running the scripts
#   * Check for eZFind extension, if it is there, remind the user to add these entries:
#     * <field name="ezf_df_tags" type="lckeyword" indexed="true" stored="true" multiValued="true" termVectors="true"/>
#     * <field name="ezf_df_tag_ids" type="sint" indexed="true" stored="true" multiValued="true" termVectors="true"/>
#     to the extension/ezfind/java/solr/ezp-default/conf/schema.xml file
#


# Exit on error
set -e

# dbname=""
if [ -z "${1+x}" ]; then
    read -p "Enter the DB name to upgrade: " dbname
    if [ "${dbname}" == "" ]; then
        echo "I can't continue, I need a DB to upgrade"
        exit 2;
    fi
else
    dbname="$1"
fi

# siteaccess=""
if [ -z "${2+x}" ]; then
    read -p "Enter the site access to use during the upgrade: " siteaccess
    if [ "${siteaccess}" == "" ]; then
        echo "I can't continue, I need a site access to use during the upgrade"
        exit 3;
    fi
else
    siteaccess="$2"
fi

# DB User
dbuser="root"
environment="prod"

# DB Password
read -s -p "Enter Password: " mypassword

current_dir=$(pwd)
[ -d ezpublish_legacy ] && cd ezpublish_legacy;

# Thinks to check after the upgrade
checkfor_ezi18n=0
checkfor_eztemplateinit=0

echo "Upgrading database"

# echo "updating to 4.0", previous version 3.10
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d\d?' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "3.10" ]; then
    echo "updating DB 3.10 to 4.1"
    checkfor_ezi18n=1
    checkfor_eztemplateinit=1
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/4.0/dbupdate-3.10.0-to-4.0.0.sql
    php update/common/scripts/4.0/updatebinaryfile.php --siteaccess=${siteaccess}
    php update/common/scripts/4.0/updatetipafriendpolicy.php --siteaccess=${siteaccess}
    php update/common/scripts/4.0/updatevatcountries.php --siteaccess=${siteaccess}
else
    echo "Skipping 3.10 to 4.1"
fi

# echo "updating to 4.1", previous version 4.0
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "4.0" ]; then
    echo "updating DB 4.0 to 4.1"
    checkfor_ezi18n=1
    checkfor_eztemplateinit=1
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/4.1/dbupdate-4.0.0-to-4.1.0.sql
    php update/common/scripts/4.1/addlockstategroup.php  --siteaccess=${siteaccess}
    php update/common/scripts/4.1/correctxmlalign.php  --siteaccess=${siteaccess}
    php update/common/scripts/4.1/fixclassremoteid.php  --siteaccess=${siteaccess}
    php update/common/scripts/4.1/fixezurlobjectlinks.php  --siteaccess=${siteaccess}
    php update/common/scripts/4.1/fixnoderemoteid.php  --siteaccess=${siteaccess}
    php update/common/scripts/4.1/fixobjectremoteid.php  --siteaccess=${siteaccess}
    php update/common/scripts/4.1/initurlaliasmlid.php  --siteaccess=${siteaccess}
    php update/common/scripts/4.1/updateimagesystem.php  --siteaccess=${siteaccess}
else
    echo "Skipping 4.0 to 4.1"
fi

# echo "updating to 4.2", previous version 4.1
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "4.1" ]; then
    echo "updating DB 4.1 to 4.2"
    checkfor_ezi18n=1
    checkfor_eztemplateinit=1
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/4.2/dbupdate-4.1.0-to-4.2.0.sql
    php update/common/scripts/4.2/fixorphanimages.php --siteaccess=${siteaccess}
else
    echo "Skipping 4.1 to 4.2"
fi

# echo "updating to 4.3", previous version 4.2
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "4.2" ]; then
    echo "updating DB 4.2 to 4.3"
    checkfor_ezi18n=1
    checkfor_eztemplateinit=1
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/4.3/dbupdate-4.2.0-to-4.3.0.sql
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/4.3/dbupdate-cluster-4.2.0-to-4.3.0.sql
    php update/common/scripts/4.3/updatenodeassignment.php --siteaccess=${siteaccess}
else
    echo "Skipping 4.2 to 4.3"
fi

# echo "updating to 4.4", previous version 4.3
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "4.3" ]; then
    echo "updating DB 4.3 to 4.4"
    checkfor_ezi18n=1
    checkfor_eztemplateinit=1
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/4.4/dbupdate-4.3.0-to-4.4.0.sql
    php update/common/scripts/4.4/updatesectionidentifier.php --siteaccess=${siteaccess}
else
    echo "Skipping 4.3 to 4.4"
fi

# echo "updating to 4.5", previous version 4.4
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "4.4" ]; then
    echo "updating DB 4.4 to 4.5"
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/4.5/dbupdate-4.4.0-to-4.5.0.sql
    php update/common/scripts/4.5/updatesectionidentifier.php --siteaccess=${siteaccess}
else
    echo "Skipping 4.4 to 4.5"
fi

# echo "updating to 4.6", previous version 4.5
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "4.5" ]; then
    echo "updating DB 4.5 to 4.6"
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/4.6/dbupdate-4.5.0-to-4.6.0.sql
    php update/common/scripts/4.6/removetrashedimages.php -n --siteaccess=${siteaccess}
    php update/common/scripts/4.6/updateordernumber.php --siteaccess=${siteaccess}
else
    echo "Skipping 4.5 to 4.6"
fi

# echo "updating to 4.7", previous version 4.6
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "4.6" ]; then
    echo "updating DB 4.6 to 4.7"
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/4.7/dbupdate-4.6.0-to-4.7.0.sql
    # Cluster setup
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/4.7/dbupdate-cluster-4.6.0-to-4.7.0.sql
else
    echo "Skipping 4.6 to 4.7"
fi

# echo "updating to 5.0", previous version 4.7
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "4.7" ]; then
    echo "updating DB 4.7 to 5.0"
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/5.0/dbupdate-4.7.0-to-5.0.0.sql
    php update/common/scripts/5.0/deduplicatecontentstategrouplanguage.php --siteaccess=${siteaccess}
    php update/common/scripts/5.0/restorexmlrelations.php --siteaccess=${siteaccess}
    php update/common/scripts/5.0/disablesuspicioususers.php --disable --siteaccess=${siteaccess}
else
    echo "Skipping 4.7 to 5.0"
fi

# echo "updating to 5.1", previous version 5.0
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "5.0" ]; then
    echo "updating DB 5.0 to 5.1"
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/5.1/dbupdate-5.0.0-to-5.1.0.sql
    php update/common/scripts/5.1/fiximagesoutsidevardir.php --siteaccess=${siteaccess}
else
    echo "Skipping 5.0 to 5.1"
fi

# echo "updating to 5.2", previous version 5.1
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "5.1" ]; then
    echo "updating DB 5.1 to 5.2"
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/5.2/dbupdate-5.1.0-to-5.2.0.sql
    # php update/common/scripts/5.2/cleanupdfscache.php --siteaccess=${siteaccess}
else
    echo "Skipping 5.1 to 5.2"
fi

# echo "updating to 5.3", previous version 5.2
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "5.2" ]; then
    echo "updating DB 5.2 to 5.3"
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/5.3/dbupdate-5.2.0-to-5.3.0.sql
    php update/common/scripts/5.3/recreateimagesreferences.php --siteaccess=${siteaccess}
    php update/common/scripts/5.3/updatenodeassignmentparentremoteids.php --siteaccess=${siteaccess}
else
    echo "Skipping 5.2 to 5.3"
fi

# echo "updating to 5.4", previous version 5.3
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
if [ "${ezp_version}" == "5.3" ]; then
    echo "updating DB 5.3 to 5.4"
    mysql -u$dbuser -p"${mypassword}" $dbname < update/database/mysql/5.4/dbupdate-5.3.0-to-5.4.0.sql
else
    echo "Skipping 5.3 to 5.4"
fi

# echo "updating to lovestack", previous version 5.4
ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Current eZ Publish DB version: ${ezp_version}"
checkfor_php55=0
if [ "${ezp_version}" == "5.4" ] || [ "${ezp_version}" == "5.9" ]; then
    echo "updating DB ${ezp_version} to lovestack"
    checkfor_php55=1
    php update/run.php -u ${dbuser} -d ${dbname} -p ${mypassword}
else
    echo "Skipping ${ezp_version} to lovestack"
fi

ezp_version=$( mysql -u$dbuser -p"${mypassword}" ${dbname} -BNe "SELECT value FROM ezsite_data WHERE name='ezpublish-version'" | grep -Po '^\d\.\d' )
echo "Final eZ Publish DB version: ${ezp_version}"

sleep 2

php bin/php/ezpgenerateautoloads.php --extension

php bin/php/ezcache.php --clear-all

# return to the initial directory
cd $current_dir

# [ -d ezpublish_legacy ] && php ezpublish/console assets:install --symlink
# [ -d ezpublish_legacy ] && php ezpublish/console ezpublish:legacy:assets_install --symlink
# [ -d ezpublish_legacy ] && php ezpublish/console assetic:dump --env=${environment}

# [ -d ezpublish_legacy ] && echo "Clearing new stack cache"
# [ -d ezpublish_legacy ] && php ezpublish/console cache:clear

# Things to checkup after the update
if [ $checkfor_ezi18n eq 1 ]; then
    echo "Check for the usage of ezi18n function deprecated in 4.3, removed on 4.4 change it with ezpI18n::tr."
fi

if [ $checkfor_eztemplateinit eq 1 ]; then
    echo "Check for the usage of eztemplateinit() function deprecated in 4.3 in favor of eZTemplate::factory()."
fi

if [ $checkfor_php55 eq 1 ]; then
    echo "PHP > 5.5 is required"
fi

exit 0

