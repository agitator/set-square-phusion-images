defineEnvVar MARIADB_ROOT_PASSWORD "The password for the root user" "${RANDOM_PASSWORD}";
defineEnvVar MARIADB_ADMIN_USER "The admin user" "dbadmin";
defineEnvVar MARIADB_ADMIN_PASSWORD "The password for the admin user" "${RANDOM_PASSWORD}";
defineEnvVar MARIADB_ADMIN_PRIVILEGES "The default privileges for the admin user" "ALL PRIVILEGES";
overrideEnvVar ENABLE_CRON false;
overrideEnvVar ENABLE_MONIT true;
overrideEnvVar ENABLE_RSNAPSHOT true;
overrideEnvVar ENABLE_SYSLOG true;
#overrideEnvVar ENABLE_LOGSTASH false;
