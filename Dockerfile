FROM frekele/debian:stable

MAINTAINER frekele <leandro.freitas@softdevelop.com.br>

# Set environment variables for program versions
ENV JDK_VERSION=7
ENV JDK_UPDATE=75
ENV JDK_BUILD=b13
ENV JDK_DISTRO_ARCH=linux-x64

ENV JCE_FOLDER=UnlimitedJCEPolicy
ENV JDK_FOLDER=jdk1.$JDK_VERSION.0_$JDK_UPDATE
ENV JDK_VERSION_UPDATE=$JDK_VERSION'u'$JDK_UPDATE
ENV JDK_VERSION_UPDATE_BUILD=$JDK_VERSION_UPDATE'-'$JDK_BUILD
ENV JDK_VERSION_UPDATE_DISTRO_ARCH=$JDK_VERSION_UPDATE'-'$JDK_DISTRO_ARCH

ENV JAVA_HOME=/opt/java
ENV JRE_SECURITY_FOLDER=$JAVA_HOME/jre/lib/security
ENV SSL_TRUSTED_CERTS_FOLDER=/opt/ssl/trusted

# Change to tmp folder
WORKDIR /tmp

# Download and extract jdk to opt folder
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
       http://download.oracle.com/otn-pub/java/jdk/${JDK_VERSION_UPDATE_BUILD}/jdk-${JDK_VERSION_UPDATE_DISTRO_ARCH}.tar.gz \
    && wget --no-check-certificate --no-cookies https://www.oracle.com/webfolder/s/digest/${JDK_VERSION_UPDATE}checksum.html \
    && grep -o "<tr><td>jdk-${JDK_VERSION_UPDATE_DISTRO_ARCH}.tar.gz</td>.*</tr>" ${JDK_VERSION_UPDATE}checksum.html \
        | sed 's/\(<tr>\|<\/tr>\)//g' \
        | sed 's/\(<td>\|<\/td>\)//g' \
        | sed 's/\(<br>\|<\/br>\)//g' \
        | sed "s/\(jdk-${JDK_VERSION_UPDATE_DISTRO_ARCH}.tar.gz\)//g" \
        | awk '{ print $1 }' > jdk-${JDK_VERSION_UPDATE_DISTRO_ARCH}.tar.gz.md5 \
    && echo "$(cat jdk-${JDK_VERSION_UPDATE_DISTRO_ARCH}.tar.gz.md5) jdk-${JDK_VERSION_UPDATE_DISTRO_ARCH}.tar.gz" | md5sum -c \
    && tar -zvxf jdk-${JDK_VERSION_UPDATE_DISTRO_ARCH}.tar.gz -C /opt \
    && ln -s /opt/${JDK_FOLDER} /opt/java \
    && rm -f ${JDK_VERSION_UPDATE}checksum.html \
    && rm -f jdk-${JDK_VERSION_UPDATE_DISTRO_ARCH}.tar.gz \
    && rm -f jdk-${JDK_VERSION_UPDATE_DISTRO_ARCH}.tar.gz.md5

# Download zip file with java cryptography extension and unzip to jre security folder
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
       http://download.oracle.com/otn-pub/java/jce/${JDK_VERSION}/UnlimitedJCEPolicyJDK${JDK_VERSION}.zip \
    && unzip UnlimitedJCEPolicyJDK${JDK_VERSION}.zip \
    && cp ${JCE_FOLDER}/*.jar ${JRE_SECURITY_FOLDER} \
    && rm -f UnlimitedJCEPolicyJDK${JDK_VERSION}.zip \
    && rm -rf ${JCE_FOLDER}
    
# Add executables to path
RUN update-alternatives --install "/usr/bin/java" "java" "/opt/java/bin/java" 1 && \
    update-alternatives --set "java" "/opt/java/bin/java" && \
    update-alternatives --install "/usr/bin/javac" "javac" "/opt/java/bin/javac" 1 && \
    update-alternatives --set "javac" "/opt/java/bin/javac" && \
    update-alternatives --install "/usr/bin/keytool" "keytool" "/opt/java/bin/keytool" 1 && \
    update-alternatives --set "keytool" "/opt/java/bin/keytool"

# Create trusted ssl certs folder
RUN mkdir -p $SSL_TRUSTED_CERTS_FOLDER

# Mark as volume
VOLUME $SSL_TRUSTED_CERTS_FOLDER

# Add the files
ADD rootfs /

# Change to root folder
WORKDIR /root

