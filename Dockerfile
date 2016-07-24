FROM frekele/debian:stable

MAINTAINER frekele <leandro.freitas@softdevelop.com.br>

# set environment variables for program versions
# Use Java CPU (8u91) NOT use PSU (8u92).
ENV JDK_VERSION=8
ENV JDK_UPDATE=102
ENV JDK_BUILD=b14
ENV JDK_DISTRO_ARCH=linux-x64
ENV MAVEN_VERSION=3.3.9

ENV JCE_FOLDER=UnlimitedJCEPolicyJDK$JDK_VERSION
ENV JDK_FOLDER=jdk1.$JDK_VERSION.0_$JDK_UPDATE
ENV JDK_VERSION_UPDATE=$JDK_VERSION'u'$JDK_UPDATE
ENV JDK_VERSION_UPDATE_BUILD=$JDK_VERSION_UPDATE'-'$JDK_BUILD
ENV JDK_VERSION_UPDATE_DISTRO_ARCH=$JDK_VERSION_UPDATE'-'$JDK_DISTRO_ARCH

ENV JAVA_HOME=/opt/java
ENV JRE_SECURITY_FOLDER=$JAVA_HOME/jre/lib/security
ENV SSL_TRUSTED_CERTS_FOLDER=/opt/ssl/trusted
ENV MAVEN_HOME=/opt/mvn

# Change to tmp folder
WORKDIR /tmp

# Download and extract jdk to opt folder
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/$JDK_VERSION_UPDATE_BUILD/jdk-$JDK_VERSION_UPDATE_DISTRO_ARCH.tar.gz \
    && wget --no-check-certificate --no-cookies https://www.oracle.com/webfolder/s/digest/${JDK_VERSION_UPDATE}checksum.html \
    && grep -o '<tr><td>jdk-$JDK_VERSION_UPDATE_DISTRO_ARCH.tar.gz</td>.*</tr>' ${JDK_VERSION_UPDATE}checksum.html \
        | sed 's/\(<tr>\|<\/tr>\)//g' \
        | sed 's/\(<td>\|<\/td>\)//g' \
        | sed 's/\(<br>\|<\/br>\)//g' \
        | sed 's/\(jdk-8u102-linux-i586.tar.gz\)//g' \
        | awk '{ print $2 }' > jdk-$JDK_VERSION_UPDATE_DISTRO_ARCH.tar.gz.sha256 \
    && grep -o '<tr><td>jdk-$JDK_VERSION_UPDATE_DISTRO_ARCH.tar.gz</td>.*</tr>' ${JDK_VERSION_UPDATE}checksum.html \
        | sed 's/\(<tr>\|<\/tr>\)//g' \
        | sed 's/\(<td>\|<\/td>\)//g' \
        | sed 's/\(<br>\|<\/br>\)//g' \
        | sed 's/\(jdk-8u102-linux-i586.tar.gz\)//g' \
        | awk '{ print $4 }' > jdk-$JDK_VERSION_UPDATE_DISTRO_ARCH.tar.gz.md5 \
    && echo "$(cat jdk-$JDK_VERSION_UPDATE_DISTRO_ARCH.tar.gz.md5) jdk-${JDK_VERSION_UPDATE_DISTRO_ARCH}.tar.gz" | md5sum -c \
    && echo "$(cat jdk-$JDK_VERSION_UPDATE_DISTRO_ARCH.tar.gz.sha256) jdk-${JDK_VERSION_UPDATE_DISTRO_ARCH}.tar.gz" | sha256sum -c \
    && tar -zvxf jdk-$JDK_VERSION_UPDATE_DISTRO_ARCH.tar.gz -C /opt \
    && ln -s /opt/$JDK_FOLDER /opt/java \
    && rm -f ${JDK_VERSION_UPDATE}checksum.html \
    && rm -f jdk-$JDK_VERSION_UPDATE_DISTRO_ARCH.tar.gz \
    && rm -f jdk-$JDK_VERSION_UPDATE_DISTRO_ARCH.tar.gz.md5 \
    && rm -f jdk-$JDK_VERSION_UPDATE_DISTRO_ARCH.tar.gz.sha256
    

# Create trusted ssl certs folder
RUN mkdir -p $SSL_TRUSTED_CERTS_FOLDER

# Mark as volume
VOLUME $SSL_TRUSTED_CERTS_FOLDER

# Add the files
ADD rootfs /

# Change to root folder
WORKDIR /root

