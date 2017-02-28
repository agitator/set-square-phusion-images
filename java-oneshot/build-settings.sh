defineEnvVar PARENT_IMAGE_TAG "The tag of the parent image" "201702";
defineEnvVar DEFAULT_JAVA_OPTS "The default Java opts" "-Djava.security.egd=file:/dev/./urandom";
defineEnvVar APP_HOME "The home of the Java app" "/opt/java-app";
defineEnvVar JAVA_DEFAULT_LOCALE "The default locale" "es_ES";
defineEnvVar JAVA_DEFAULT_ENCODING "The default encoding" "UTF-8";
defineEnvVar ENABLE_CRON "Whether cron is enabled" "false";
defineEnvVar ENABLE_MONIT "Whether monit is enabled" "false";
defineEnvVar ENABLE_RSNAPSHOT "Whether rsnapshot is enabled" "false";
defineEnvVar ENABLE_SSH "Whether ssh is enabled" "false";
defineEnvVar ENABLE_SYSLOG "Whether syslog is enabled" "true";
defineEnvVar ENABLE_LOCAL_SMTP "Whether local SMTP is enabled" "true";
defineEnvVar ENABLE_LOGSTASH "Whether logstash is enabled" "false";
defineEnvVar SERVICE_USER "The service user" "osoco";
defineEnvVar SERVICE_GROUP "The service group" "osoco";
defineEnvVar SERVICE_USER_SHELL "The shell of the service user" "/bin/bash";
defineEnvVar SERVICE_USER_HOME "The home of the service user" '${APP_HOME}';
