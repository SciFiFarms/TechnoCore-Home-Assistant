#!/usr/bin/env python
import hiyapyco
import re

# Currently the entrypoint.sh uses arguments that are ignored in this file. 
# https://github.com/zerwes/hiyapyco/blob/master/examples/hiyapyco_example.py
merged_yaml = hiyapyco.load('/etc/home-assistant/default-configuration.yaml', '/config/custom-configuration.yaml', method=hiyapyco.METHOD_MERGE)

config = re.sub(
    pattern=r'\'!(.*)\'', 
    repl='!\\1', 
    string=hiyapyco.dump(merged_yaml)
)
with open("/config/configuration.yaml", "w") as configuration:
    configuration.write("# DO NOT EDIT THIS FILE. It will be regenerated upon container startup. Instead, edit /config/custom-configuration.yaml. \n")
    configuration.write(config)
