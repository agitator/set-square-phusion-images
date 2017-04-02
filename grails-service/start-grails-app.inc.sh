defineEnvVar PROCESS_FILE "The process-file.sh script" "/usr/local/bin/process-file.sh";
defineEnvVar DB_HOST "The database host" '${DEFAULT_DB_HOST}';
defineEnvVar DB_PORT "The database port" '${DEFAULT_DB_PORT}';
defineEnvVar DB_CONNECTION_POOL_INITIAL_SIZE "The initial size of the DB connection pool" '${DEFAULT_DB_CONNECTION_POOL_INITIAL_SIZE}';
defineEnvVar DB_CONNECTION_POOL_MAX_ACTIVE "The maximum active connections" '${DEFAULT_DB_CONNECTION_POOL_MAX_ACTIVE}';
defineEnvVar DB_CONNECTION_POOL_MIN_IDLE "The minimum number of idle connections" '${DEFAULT_DB_CONNECTION_POOL_MIN_IDLE}';
defineEnvVar DB_CONNECTION_POOL_MAX_IDLE "The maximum number of idle connections" '${DEFAULT_DB_CONNECTION_POOL_MAX_IDLE}';
defineEnvVar DB_CONNECTION_POOL_MAX_WAIT "The maximum waiting time" '${DEFAULT_DB_CONNECTION_POOL_MAX_WAIT}';
defineEnvVar DB_CONNECTION_POOL_MAX_AGE "The longest-lived connection in the pool" '${DEFAULT_DB_CONNECTION_POOL_MAX_AGE}';
defineEnvVar DB_CONNECTION_POOL_TIME_BETWEEN_EVICTION_RUNS_MILLIS "Time between eviction runs, in milliseconds" '${DEFAULT_DB_CONNECTION_POOL_TIME_BETWEEN_EVICTION_RUNS_MILLIS}';
defineEnvVar DB_CONNECTION_POOL_MIN_EVICTABLE_IDLE_TIME_MILLIS "Minimum time in idle, in milliseconds" '${DEFAULT_DB_CONNECTION_POOL_MIN_EVICTABLE_IDLE_TIME_MILLIS}';
defineEnvVar DB_CONNECTION_POOL_VALIDATION_QUERY "The validation query" '${DEFAULT_DB_CONNECTION_POOL_VALIDATION_QUERY}';
defineEnvVar DB_CONNECTION_POOL_VALIDATION_QUERY_TIMEOUT "The timeout of the validation query" '${DEFAULT_DB_CONNECTION_POOL_VALIDATION_QUERY_TIMEOUT}';
defineEnvVar DB_CONNECTION_POOL_VALIDATION_INTERVAL "Time between the validation query runs" '${DEFAULT_DB_CONNECTION_POOL_VALIDATION_INTERVAL}';
defineEnvVar DB_CONNECTION_POOL_TEST_ON_BORROW "Whether to test connections on borrow" '${DEFAULT_DB_CONNECTION_POOL_TEST_ON_BORROW}';
defineEnvVar DB_CONNECTION_POOL_TEST_WHILE_IDLE "Whether to test connections while idle" '${DEFAULT_DB_CONNECTION_POOL_TEST_WHILE_IDLE}';
defineEnvVar DB_CONNECTION_POOL_TEST_ON_RETURN "Whether to test connections on return" '${DEFAULT_DB_CONNECTION_POOL_TEST_ON_RETURN}';
defineEnvVar DB_CONNECTION_POOL_JDBC_INTERCEPTORS "The JDBC interceptors" '${DEFAULT_DB_CONNECTION_POOL_JDBC_INTERCEPTORS}';
defineEnvVar DB_CONNECTION_POOL_DEFAULT_TRANSACTION_ISOLATION "The default transaction isolation" '${DEFAULT_DB_CONNECTION_POOL_DEFAULT_TRANSACTION_ISOLATION}';
defineEnvVar RABBITMQ_CONNECTION_NAME "The connection name" '${DEFAULT_RABBITMQ_CONNECTION_NAME}';
defineEnvVar RABBITMQ_HOST "The RabbitMQ host" '${DEFAULT_RABBITMQ_HOST}';
defineEnvVar RABBITMQ_USERNAME "The RabbitMQ username" '${DEFAULT_RABBITMQ_USERNAME}';
defineEnvVar RABBITMQ_PASSWORD "The RabbitMQ password" '${DEFAULT_RABBITMQ_PASSWORD}';
defineEnvVar GRAILS_SERVER_URL "The Grails server url" '${DEFAULT_GRAILS_SERVER_URL}';
defineEnvVar GRAILS_ASSETS_URL "The assets url" '${DEFAULT_GRAILS_ASSETS_URL}';
