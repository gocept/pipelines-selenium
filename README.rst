Pipeline Selenium
=================

This repository can setup a docker image, which includes a python stack,
firefox and selenium ready for running with bitbucket pipelines.


Build the image
---------------

To build the image::

    $ docker build -t gocept/pipelines-selenium .


Local test run
--------------

Run the container with a source repository (here gocept.selenium) mounted on a
local machine::

    $ docker run -it --volume=/path/to/gocept.selenium:/gocept.selenium --workdir="/gocept.selenium" gocept/pipelines-selenium

Test can be run with using ``tox`` now.


Versions
--------

2.0
+++

This version is backwards incompatible to 1.0 as it includes no selenium server
but:

    - Current Firefox version
    - Gecko driver to enable webdriver control
    - Xvfb to run the tests in this buffer.
    - tox

1.0
+++

This version includes:

    - Firefox 45.0
    - Selenium Server 2.53.1
    - tox
