Installation
============

Option 1: HACS
--------------

Under HACS -> Integrations, select “+”, search for ``pyscript`` and
install it.

Option 2: Manual
----------------

From the `latest release <https://github.com/custom-components/pyscript/releases>`__
download the zip file ``hass-custom-pyscript.zip``

.. code:: bash

   cd YOUR_HASS_CONFIG_DIRECTORY    # same place as configuration.yaml
   mkdir -p custom_components/pyscript
   cd custom_components/pyscript
   unzip hass-custom-pyscript.zip

Alternatively, you can install the current GitHub master version by
cloning and copying:

.. code:: bash

   mkdir SOME_LOCAL_WORKSPACE
   cd SOME_LOCAL_WORKSPACE
   git clone https://github.com/custom-components/pyscript.git
   mkdir -p YOUR_HASS_CONFIG_DIRECTORY/custom_components
   cp -pr pyscript/custom_components/pyscript YOUR_HASS_CONFIG_DIRECTORY/custom_components

Install Jupyter Kernel
----------------------

Installing the Pyscript Jupyter kernel is optional but highly recommended.
The steps to install and use it are in this
`README <https://github.com/craigbarratt/hass-pyscript-jupyter/blob/master/README.md>`__.
