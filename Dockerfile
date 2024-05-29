FROM ubuntu:latest

RUN apt-get update && apt-get install -y software-properties-common vim git wget
RUN apt-get install -y openjdk-8-jdk openjdk-8-jre
RUN apt-get install -y python-is-python3 python3-pip

RUN mkdir /dist

RUN wget -O /dist/hbase-2.5.2-bin.tar.gz  https://archive.apache.org/dist/hbase/2.5.2/hbase-2.5.2-bin.tar.gz
RUN tar xzvf /dist/hbase-2.5.2-bin.tar.gz  -C /dist/
RUN rm -rf /dist/hbase-2.5.2-bin.tar.gz

RUN wget -O /dist/phoenix-hbase-2.5-5.1.3-bin.tar.gz https://dlcdn.apache.org/phoenix/phoenix-5.1.3/phoenix-hbase-2.5-5.1.3-bin.tar.gz
RUN tar xzvf /dist/phoenix-hbase-2.5-5.1.3-bin.tar.gz -C /dist/
RUN rm -rf /dist/phoenix-hbase-2.5-5.1.3-bin.tar.gz
RUN cp /dist/phoenix-hbase-2.5-5.1.3-bin/phoenix-server-hbase-2.5-5.1.3.jar /dist/hbase-2.5.2/lib/phoenix-server-hbase-2.5-5.1.3.jar


RUN echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-arm64" >> /dist/hbase-2.5.2/conf/hbase-env.sh
RUN echo "JRE_HOME=/usr/lib/jvm/java-1.8.0-openjdk-arm64" >> /dist/hbase-2.5.2/conf/hbase-env.sh
RUN echo "export HBASE_MANAGES_ZK=true" >> /dist/hbase-2.5.2/conf/hbase-env.sh

RUN wget -O /dist/spark-3.3.1-bin-hadoop3.tgz https://archive.apache.org/dist/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz
RUN tar xzvf /dist/spark-3.3.1-bin-hadoop3.tgz -C /dist/
RUN rm -rf /dist/spark-3.3.1-bin-hadoop3.tgz

RUN pip install jupyter
RUN cp /dist/spark-3.3.1-bin-hadoop3/conf/spark-env.sh.template /dist/spark-3.3.1-bin-hadoop3/conf/spark-env.sh
RUN cp /dist/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf.template /dist/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf
RUN echo "export PYSPARK_DRIVER_PYTHON=jupyter" >> /dist/spark-3.3.1-bin-hadoop3/conf/spark-env.sh
RUN echo "PYSPARK_DRIVER_PYTHON_OPTS='notebook --allow-root --no-browser --ip 0.0.0.0 --notebook-dir=/src/'" >> /dist/spark-3.3.1-bin-hadoop3/conf/spark-env.sh
RUN echo "spark.driver.extraClassPath /dist/hbase-2.5.2/conf:$(/dist/hbase-2.5.2/bin/hbase mapredcp):/dist/spark-3.3.1-bin-hadoop3/jars/phoenix5-spark3-shaded-6.0.0.7.2.16.0-287.jar" >> /dist/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf
RUN echo "spark.executor.extraClassPath /dist/hbase-2.5.2/conf:$(/dist/hbase-2.5.2/bin/hbase mapredcp):/dist/spark-3.3.1-bin-hadoop3/jars/phoenix5-spark3-shaded-6.0.0.7.2.16.0-287.jar" >> /dist/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf

RUN wget -O /dist/phoenix5-spark3-shaded-6.0.0.7.2.16.0-287.jar https://repository.cloudera.com/artifactory/cloudera-repos/org/apache/phoenix/phoenix5-spark3-shaded/6.0.0.7.2.16.0-287/phoenix5-spark3-shaded-6.0.0.7.2.16.0-287.jar
RUN mv /dist/phoenix5-spark3-shaded-6.0.0.7.2.16.0-287.jar /dist/spark-3.3.1-bin-hadoop3/jars/phoenix5-spark3-shaded-6.0.0.7.2.16.0-287.jar

RUN mkdir /src
COPY /src/* /src/

RUN mkdir /scripts
COPY /scripts/*  /scripts/
RUN chmod +x /scripts/container_start.sh

EXPOSE 8888

CMD /scripts/container_start.sh
