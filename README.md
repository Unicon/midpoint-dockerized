## Overview
This Docker image contains Evolveum midPoint running on OpenJDK-based Zulu and Apache Tomcat running on the latest CentOS 7 base. This image is a base image and should be used to set the configuration with local changes. 

A working example of how this image can be used can be found at https://github.com/UniconLabs/dockerized-midpoint-testbed.

## Tags
Currently maintained tags:

* lastest: master branch
* 3.6.0 - The latest 3.6.0 image
* 3.5.1 - The latest 3.5.1 image

Retired tags:
* None

Retired tags contain a valid version of the IdP, but are no longer rev'd when new Java and Jetty releaseds are made. Other tags may exists but either are no longer maintained or are not considered production ready.

There are also date-based tags tied to versions to allow users to maintain consistency between minor changes, such as Tomcat or Java version upgrades. See https://github.com/Unicon/shibboleth-midpoint-dockerized/wiki/Tags for details.


## Using the Image
You can use this image as a base image for one's own IdP deployment. Assuming that you have a layout with your configuration, credentials, and war customizations (see above). The directory structure could look like:

```
[basedir]
|-- .dockerignore
|-- Dockerfile
|-- shibboleth-idp/
|   |-- conf/
|   |   |-- attribute-filter.xml
|   |   |-- attribute-resolver.xml
|   |   |-- credentials.xml
|   |   |-- idp.properties
|   |   |-- ldap.properties
|   |   |-- login.config
|   |   |-- metadata-providers.xml
|   |   |-- relying-party.xml
|   |   |-- services.xml
|   |-- credentials/
|   |   |-- idp-backchannel.crt
|   |   |-- idp-backchannel.p12
|   |   |-- idp-browser.p12
|   |   |-- idp-encryption.crt
|   |   |-- idp-encryption.key
|   |   |-- idp-signing.crt
|   |   |-- idp-signing.key
|   |   |-- sealer.jks
|   |   |-- sealer.kver
|   |-- metadata/
|   |   |-- idp-metadata.xml
|   |   |-- [sp metadatafiles]
|   |-- webapp/
|   |   |-- images/
|   |   |   |-- dummylogo-mobile.png
|   |   |   |-- dummylogo.png
|   |   |-- WEB-INF/
|   |   |   |-- web.xml
|   |-- views/
|   |   |   |-- login.vm
|   |   |   |-- logout.vm
```

Next, assuming you create a Dockerfile similar to this example:

```
FROM unicon/midpoint

MAINTAINER <your_contact_email>

ADD shibboleth-idp/ /opt/midpoint/
```

The dependant image can be built by running:

```
docker pull centos:centos7
docker build --tag="<org_id>/midpoint:<version>" .
```

> This will download the base image from the Docker Hub repository. Next, your files are overlaid replacing the base image's counter-parts.

Now, execute the new/customized image:

```
$ docker run -d --name="midpoint-local-test" <org_id>/midpoint
```


### Volume Mount
The midpoint container does not explicitally need any volumes mapped for operation, but the option does exist using the following format:

* `-v <hostDir:containerDir`

It maybe desirable to map things like  `/root/midpoint/logs` or `/opt/midpoint/keystore.jceks` to host-side storage.

## Notables
There are a few things that implementors should be aware of. This images is still under development, so things may change.

## Building from source:
 
```
$ docker build --tag="<org_id>/midpoint" github.com/unicon/midpoint-dockerized
```

## Recipes
Instructions for things like use the Oracle JVM and JCE with this image can be found at <https://github.com/Unicon/midpoint-idp-dockerized/wiki/>.

## Authors/Contributors

  * John Gasper (<jgasper@unicon.net>)

## LICENSE

Copyright 2017 Unicon, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
