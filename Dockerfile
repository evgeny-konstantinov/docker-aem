FROM evege/docker-jdk

ARG AEM_VERSION="6.5.0"
ARG AEM_PORT="4502"
ARG AEM_RUNMODES="-Dsling.run.modes=author,crx3,crx3tar,nosamplecontent"
ARG WORK_DIR="/opt/aem"
ARG AEM_STDOUT_LOG="${WORK_DIR}/crx-quickstart/logs/stdout.log"
ARG AEM_JVM_OPTS="-server -Xmx2048m -Djava.awt.headless=true"
ARG AEM_START_OPTS="start -c ${WORK_DIR}/crx-quickstart -i launchpad -p ${AEM_PORT} \
-Dsling.properties=${WORK_DIR}/crx-quickstart/conf/sling.properties \
--add-opens=java.desktop/com.sun.imageio.plugins.jpeg=ALL-UNNAMED \
--add-opens=java.base/sun.net.www.protocol.jrt=ALL-UNNAMED \
--add-opens=java.naming/javax.naming.spi=ALL-UNNAMED \
--add-opens=java.xml/com.sun.org.apache.xerces.internal.dom=ALL-UNNAMED \
--add-opens=java.base/java.lang=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.loader=ALL-UNNAMED \
--add-opens=java.base/java.net=ALL-UNNAMED -Dnashorn.args=--no-deprecation-warning"
ARG AEM_JARFILE="${WORK_DIR}/crx-quickstart/app/cq-quickstart-${AEM_VERSION}-standalone-quickstart.jar"

ENV AEM_JVM_OPTS="${AEM_JVM_OPTS}" \
    AEM_START_OPTS="${AEM_START_OPTS}" \
    AEM_JARFILE="${AEM_JARFILE}" \
    AEM_RUNMODES="${AEM_RUNMODES}" \
    AEM_STDOUT_LOG="${AEM_STDOUT_LOG}"

WORKDIR ${WORK_DIR}
COPY jar/aem-quickstart.jar ./aem-quickstart.jar

#unpack the jar
RUN java -jar aem-quickstart.jar -unpack && \
    rm aem-quickstart.jar

COPY scripts/*.sh ./crx-quickstart/bin

COPY dist/install.first/*.config ./crx-quickstart/install/
COPY dist/install.first/logs/*.config ./crx-quickstart/install/
COPY dist/install.first/conf/sling.properties ./crx-quickstart/conf/sling.properties

#expose port
EXPOSE ${AEM_PORT} 58242 57345 57346

VOLUME ["${WORK_DIR}/crx-quickstart/repository", "${WORK_DIR}/crx-quickstart/logs"]

#ensure script has exec permissions
RUN chmod +x ${WORK_DIR}/crx-quickstart/bin/*.sh

#make java pid 1
ENTRYPOINT ["/tini", "-v", "--", "/opt/aem/crx-quickstart/bin/run-tini.sh"]
