#!/usr/bin/env bash
# Most of this file comes from https://medium.com/@basi/docker-environment-variables-expanded-from-secrets-8fa70617b3bc 
# Thanks Basilio Vera, Rubén Norte, and Jose Manuel Cardona! 

: ${ENV_SECRETS_DIR:=/run/secrets}

env_secret_debug()
{
    if [ ! -z "$ENV_SECRETS_DEBUG" ]; then
        echo -e "\033[1m$@\033[0m"
    fi
}

# usage: env_secret_expand VAR
#    ie: env_secret_expand 'XYZ_DB_PASSWORD'
# (will check for "$XYZ_DB_PASSWORD" variable value for a placeholder that defines the
#  name of the docker secret to use instead of the original value. For example:
# XYZ_DB_PASSWORD={{DOCKER-SECRET:my-db.secret}}
env_secret_expand() {
    var="$1"
    eval val=\$$var
    if secret_name=$(expr match "$val" "{{DOCKER-SECRET:\([^}]\+\)}}$"); then
        secret="${ENV_SECRETS_DIR}/${secret_name}"
        env_secret_debug "Secret file for $var: $secret"
        if [ -f "$secret" ]; then
            val=$(cat "${secret}")
            export "$var"="$val"
            env_secret_debug "Expanded variable: $var=$val"
        else
            env_secret_debug "Secret file does not exist! $secret"
        fi
    fi
}

env_secrets_expand() {
    for env_var in $(printenv | cut -f1 -d"=")
    do
        env_secret_expand $env_var
    done

    if [ ! -z "$ENV_SECRETS_DEBUG" ]; then
        echo -e "\n\033[1mExpanded environment variables\033[0m"
        printenv
    fi
}
env_secrets_expand

# Add any additional script here. 
#dogfish migrate &
#source /usr/share/mqtt-scripts/init.sh 
until mosquitto_pub -i test_connection -h mqtt -p 8883 -q 0 \
    -t test/network/up \
    -m "A message" \
    -u "$(cat /run/secrets/mqtt_username)" \
    -P "$(cat /run/secrets/mqtt_password)" \
    --cafile /run/secrets/ca 2> /dev/null
do
    echo "Couldn't reach MQTT. Will retry in 5 seconds."
    sleep 5
done

mkdir /run/frames
echo "https://$(cat /run/secrets/domain):6052" > /run/frames/esphome
echo "https://$(cat /run/secrets/domain)/docs" > /run/frames/docs
echo "https://$(cat /run/secrets/domain)/node_red" > /run/frames/node_red
echo "https://$(cat /run/secrets/domain)/portainer" > /run/frames/portainer
echo "https://$(cat /run/secrets/domain)/grafana" > /run/frames/grafana
echo "https://$(cat /run/secrets/domain)/grafana/explore?left=[\"now-6h\",\"now\",\"Loki\",{},{\"ui\":[true,true,true,\"none\"]}]" > /run/frames/logs
echo "https://$(cat /run/secrets/domain)/jupyter" > /run/frames/jupyter
echo "https://$(cat /run/secrets/domain)/health" > /run/frames/health

exec "$@"
