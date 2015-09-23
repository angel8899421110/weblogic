# Pull base image
# ---------------
FROM centos:7

# Maintainer
# ----------
MAINTAINER spil1ot <angel8899421110@126.com>

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV JAVA_RPM jdk-7u79-linux-x64.rpm
ENV WLS_PKG wls1036_generic.jar
ENV JAVA_HOME /usr/java/default
    
# Setup required packages (unzip), filesystem, and oracle user
# ------------------------------------------------------------
RUN mkdir /u01 && \
    chmod a+xr /u01 && \
    useradd -b /u01 -m -s /bin/bash oracle 
    
ADD https://mirror.its.sfu.ca/mirror/CentOS-Third-Party/NSG/common/x86_64/jdk-7u79-linux-x64.rpm /u01
ADD http://110.53.75.31/ws.cdn.baidupcs.com/file/33d45745ff0510381de84427a7536f65?bkt=p2-nj-90&xcode=b6c434b9ccefcade39218e8efcf93d92731b1a47717586e7ae97ca166f54709c&fid=3171195365-250528-518459699960000&time=1442979151&sign=FDTAXGERLBH-DCb740ccc5511e5e8fedcff06b081203-O80gGO2encl%2FY%2BCDfeEa2BgMhsc%3D&to=cb&fm=Nan,B,U,ny&sta_dx=1019&sta_cs=193&sta_ft=jar&sta_ct=7&fm2=Nanjing,B,U,ny&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=140033d45745ff0510381de84427a7536f65501a0ff600003fb01e53&sl=75563087&expires=8h&rt=sh&r=341870676&mlogid=6157252063499502752&vuk=3171195365&vbdid=3728790391&fin=wls1036_generic.jar&slt=pm&uta=0&rtype=1&iv=0&isw=0&dp-logid=6157252063499502752&dp-callid=0.1.1&wshc_tag=0&wsts_tag=56021d52&wsid_tag=7bea12a6&wsiphost=ipdbm /u01/

# Copy packages
#COPY /soft/$WLS_PKG /u01/
#COPY $JAVA_RPM /u01/
COPY wls-silent.xml /u01/

# Install and configure Oracle JDK
# -------------------------------------
RUN rpm -i /u01/$JAVA_RPM && \ 
    rm /u01/$JAVA_RPM

# Change the open file limits in /etc/security/limits.conf
RUN sed -i '/.*EOF/d' /etc/security/limits.conf && \
    echo "* soft nofile 16384" >> /etc/security/limits.conf && \ 
    echo "* hard nofile 16384" >> /etc/security/limits.conf && \ 
    echo "# EOF"  >> /etc/security/limits.conf

# Change the kernel parameters that need changing.
RUN echo "net.core.rmem_max=4192608" > /u01/oracle/.sysctl.conf && \
    echo "net.core.wmem_max=4192608" >> /u01/oracle/.sysctl.conf && \ 
    sysctl -e -p /u01/oracle/.sysctl.conf

# Adjust file permissions, go to /u01 as user 'oracle' to proceed with WLS installation
RUN chown oracle:oracle -R /u01
WORKDIR /u01
USER oracle

# Installation of WebLogic 
RUN java -jar $WLS_PKG -mode=silent -silent_xml=/u01/wls-silent.xml && \ 
	rm $WLS_PKG /u01/wls-silent.xml 

WORKDIR /u01/oracle/

ENV PATH $PATH:/u01/oracle/weblogic/oracle_common/common/bin

# Define default command to start bash. 
CMD ["bash"]
