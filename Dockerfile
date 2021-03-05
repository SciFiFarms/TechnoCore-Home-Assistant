FROM homeassistant/home-assistant:2021.2.3
RUN apk add --no-cache  mosquitto-clients

# This should be 4.1.something now.
RUN pip3 install -U ptvsd==4.1.4 HiYaPyCo==0.4.14
COPY config/ /config/

# Set up the CMD as well as the pre and post hooks.
COPY go-init /bin/go-init
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY exitpoint.sh /usr/bin/exitpoint.sh
COPY generate_home_assistant_configuration.py /usr/bin/
COPY configuration.yaml /etc/home-assistant/default-configuration.yaml
RUN mkdir /config/.storage/
RUN mv /config/custom-configuration.yaml /config/.storage/custom-configuration.yaml && ln -s /config/.storage/custom-configuration.yaml /config/custom-configuration.yaml
RUN cd /tmp/ && \
    git clone --depth 1  --filter=blob:none  --no-checkout https://github.com/TheHackmeister/HomeAssistant.git && \
    cd HomeAssistant && \
    git checkout master -- custom_components/compensation && \
    cp -r custom_components/compensation/ /config/custom_components/compensation/ && \
    cd ../ && \
    git clone --depth 1  --filter=blob:none  --no-checkout https://github.com/custom-components/healthchecksio.git && \
    cd healthchecksio && \
    git checkout master -- custom_components/healthchecksio && \
    cp -r custom_components/healthchecksio/ /config/custom_components/healthchecksio/ && \
    rm -rf /tmp/
ENTRYPOINT ["go-init"]
# TODO: It would be nice to figure out how to make it wait for attach here.
#CMD ["-pre", "entrypoint.sh", "-main", "python -m ptvsd --host 0.0.0.0 --port 5678 -m homeassistant --config /config ", "-post", "exitpoint.sh"]
CMD ["-main", "entrypoint.sh python -m homeassistant --config /config ", "-post", "exitpoint.sh"]

