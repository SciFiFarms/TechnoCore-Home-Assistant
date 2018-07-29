FROM homeassistant/home-assistant
#ARG userid
#ARG username
#RUN useradd --no-create-home --user-group --shell /bin/bash --uid $userid $username 
#RUN pip3 install -U ptvsd==3.0.0 # For debugging with VS Code. 
COPY config/ /config/
# This has to be in the shell form. (Not array) https://www.ctl.io/developers/blog/post/dockerfile-entrypoint-vs-cmd/
# Alternative: https://github.com/waisbrot/docker-wait
# I Have to put the sleep in because MQTT is slow to start.
CMD sleep 15 && python -m homeassistant --config /config 

# TODO: Need to prevent start until MQTT is up:
# https://docs.docker.com/compose/startup-order/