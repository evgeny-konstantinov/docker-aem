FROM evege/docker-jdk

ARG AEM_VERSION="6.5.0"
ARG AEM_JVM_OPTS="-server -Xms2048m -Xmx2048m -Djava.awt.headless=true"
ARG AEM_PORT="4502"
ARG AEM_START_OPTS="start -c /opt/aem/crx-quickstart -i launchpad -p ${AEM_PORT} -Dsling.properties=/opt/aem/crx-quickstart/conf/sling.properties -f logs/stdout.log"
ARG AEM_START_OPTS="-p ${AEM_PORT} -v"
ARG AEM_JARFILE="/opt/aem/crx-quickstart/app/cq-quickstart-${AEM_VERSION}-standalone-quickstart.jar"
ARG AEM_RUNMODE="-Dsling.run.modes=author,crx3,crx3tar,nosamplecontent"
ARG PACKAGE_PATH="./crx-quickstart/install"

ENV AEM_JVM_OPTS="${AEM_JVM_OPTS}" \
    AEM_START_OPTS="${AEM_START_OPTS}"\
    AEM_JARFILE="${AEM_JARFILE}" \
    AEM_RUNMODE="${AEM_RUNMODE}"

WORKDIR /opt/aem

COPY scripts/*.sh ./
COPY jar/aem-quickstart.jar ./aem-quickstart.jar

#unpack the jar
RUN java -jar aem-quickstart.jar -unpack && \
    rm aem-quickstart.jar

#COPY dist/install.first/*.config ./crx-quickstart/install/
COPY dist/install.first/conf/sling.properties ./crx-quickstart/conf/sling.properties
COPY jar/license.properties ./

COPY packages/ $PACKAGE_PATH/

#expose port
EXPOSE ${AEM_PORT} 58242 57345 57346

VOLUME ["/opt/aem/crx-quickstart/repository", "/opt/aem/crx-quickstart/logs"]

#ensure script has exec permissions
RUN chmod +x /opt/aem/*.sh

#make java pid 1
ENTRYPOINT ["/tini", "--", "/opt/aem/run-tini.sh"]
