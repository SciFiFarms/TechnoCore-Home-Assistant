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

echo "# Do not modify this file. It is generated in the entrypoint.sh script." > /config/links.yaml
for sidebar_item in $(printenv | grep SIDEBAR | cut -f1 -d"="); do
    # A prepended space causes this to sort to the top of the list and then gets trimmed out. 
    # In order to assign the desired order, I put them in the order I wanted, 
    # and then started at the bottom adding 1 more space than what was lower.
    title=$(echo "${!sidebar_item}" | cut -d "|" -f1)
    link=$(echo "${!sidebar_item}" | cut -d "|" -f2)
    icon=$(echo "${!sidebar_item}" | cut -d "|" -f3)
    echo "${sidebar_item,,}:" >> /config/links.yaml
    echo "  title: $title" >> /config/links.yaml
    echo "  url: https://$link/" >> /config/links.yaml
    echo "  icon: $icon" >> /config/links.yaml
done

exec "$@"
