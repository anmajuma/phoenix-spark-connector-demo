#!/bin/bash

echo ">>> Starting HBase <<<"
/dist/hbase-2.5.2/bin/start-hbase.sh
sleep 30
echo ">>> HBase started successfully <<<"

echo ">>> Create INDIA_POPULATION Phoenix Table"
/dist/phoenix-hbase-2.5-5.1.3-bin/bin/sqlline.py localhost /scripts/india_population.sql
echo ">>> INDIA_POPULATION Phoenix Table created successfully"

echo ">>> Start Spark Master"
/dist/spark-3.3.1-bin-hadoop3/sbin/start-master.sh
echo ">>> Spark Master started successfully"

echo ">>> Start PySpark"
/dist/spark-3.3.1-bin-hadoop3/bin/pyspark
