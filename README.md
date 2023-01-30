# OLAP On Apache Phoenix In Python Using Apache Spark

| - | - |
| :---        | :--- |
| ![Apache Phoenix + Apache Spark Logo](/assests/apache-phoenix-spark-connector.jpeg) | [Apache Phoenix](https://phoenix.apache.org/) is an open-source relational database engine that uses Apache HBase as it's backing store. Apache Phoenix is natively best-suited for [Online Transactional Processing (OLTP)](https://en.wikipedia.org/wiki/Online_transaction_processing) use-cases. In this article we will be exploring how we can perform [Online Analytical Processing (OLAP)](https://en.wikipedia.org/wiki/Online_analytical_processing) on Apache Phoenix using [Apache Spark](https://spark.apache.org/) analytical engine. |

## Setup

For better reading experience, I have created an Docker Image that bundles all the pre-requisites.

Firstly pull the `phoenix-spark-connector-demo` Docker Image from DockerHub using the following command -

```bash
docker pull uselesscoder/phoenix-spark-connector-demo:latest
```

Once the Docker pull is successfull, Run the container using the following command -

```bash
docker run -p 8888:8888 --name phoenix-spark-connector-demo uselesscoder/phoenix-spark-connector-demo:latest
```

Post the successful start-up of the Docker container,
 You will get a Jupter Notebook link use the same to open `phoenix_spark_read_write.ipynb` interactively running the code explained in this article.

Incase you are interested in setting up pre-requisites yourself locally,
 Please refer to the following set of documentations -

* [JDK-8](https://openjdk.org/install/)
* [Apache HBase 2.5+](https://hbase.apache.org/book.html#quickstart)
* [Apache Phoenix 5.1+](https://phoenix.apache.org/installation.html)
* [Apache Spark 3.0+](https://spark.apache.org/downloads.html)
* [Apache Phoenix's connector for Apache Spark 6.0+](https://github.com/apache/phoenix-connectors/tree/master/phoenix5-spark3#configuring-spark-to-use-the-connector)

Note for reader: I would recommend looking into the [Dockerfile](https://github.com/Abhey/phoenix-spark-connector-demo/blob/main/Dockerfile) for getting more insights on the local setup.

## Exploring Apache Phoenix's Connector For Apache Spark

In this article we will be using the [Apache Phoenix's connector for Apache Spark](https://github.com/apache/phoenix-connectors/tree/master/phoenix5-spark3).

Although Apache Spark natively supports connection to JDBC Databases like Apache Phoenix, It’s only able to parallelize queries by partioning on a numeric column. It also requires a known lower bound, upper bound and partition count in order to create split queries.

In contrast, the Apache Phoenix + Apache Spark connector is able to leverage the underlying splits provided by Phoenix in order to retrieve and save data across multiple workers. All that’s required is a database URL and a query statement. Optional SELECT columns can be given, as well as pushdown predicates for efficient filtering.

### Writing data to Apache Phoenix in Python using Apache Spark

To write data to the Apache Phoenix we use the `save` method of the DataSourceV2 API which allows us to specify the data-source type which in our case is going to be `phoenix`.
Apart from the data-source type, We need to specify the name of the table to which we want to persist the DataFrame to along with the Zookeeper quorum URL as parameters.
The column name will be derived from the field names of the DataFrame schema, and they must match the Phoenix column names.

Given a Phoenix Table with the following schema -

```SQL
CREATE TABLE IF NOT EXISTS india_population (state VARCHAR NOT NULL,city VARCHAR NOT NULL,population BIGINT CONSTRAINT india_population_pk PRIMARY KEY (state, city));
```

Here's the PySpark code for saving the data -

```python
from pyspark import Row
from pyspark.sql.types import LongType, StringType, StructField, StructType

# Create a SparkSession.
ss = SparkSession.builder.appName("phoenix-read-write").getOrCreate()

# Create table schema.
schema = StructType([
    StructField("state", StringType()), 
    StructField("city", StringType()), 
    StructField("population", LongType())
])

# Generate dummy data.
data = [
    Row("Maharastra", "Mumbai", 20667655),
    Row("West Bengal", "Kolkata", 14974073), 
    Row("Karnatka", "Bangalore", 12764935)
]

# Create a DataFrame with dummy data.
rdd = ss.sparkContext.parallelize(data)
df = ss.createDataFrame(rdd, schema)

df.write.format("phoenix").option("table", "india_population").option("zkUrl", "localhost:2181").mode("append").save()
```

Note for reader: Currenlty only `append` mode is supported by the DataFrame `save` method.

### Reading data from Apache Phoenix in Python using Apache Spark

To write data to the Apache Phoenix we use the `read` method of the DataSourceV2 API which also allows us to specify the data-source type which in our case is going to be `phoenix`.
Similar to how we did it during write, We need to pass-in table name and Zookeeper quorum URL as parameters. However, This time we don't need to specify DataFrame schema as the connector will take care of that for us.

Here's the PySpark code for reading the data that we wrote previously -

```python
ss = SparkSession.builder.appName("phoenix-read-write").getOrCreate()

df = ss.read.format("phoenix").option("table", "india_population").option("zkUrl", "localhost:2181").load()
df.show()
```

To filter a DataFrame we can use `filter` method as follows -

```python
# Data filtering approach - 1
df.filter((df.CITY == "Mumbai") | (df.STATE == "West Bengal")).show()
```

Alternatively, We can filter by loading the DataFrame to a temporary view and then running Spark-SQL queries on top of the same -

```python
# Data filtering approach - 2
df.createOrReplaceTempView("india_population_temp")
ss.sql("SELECT * FROM india_population_temp WHERE CITY='Mumbai' OR STATE='West Bengal'").show()
```

## References

This article is written using the [official documentation of the Apache Phoenix's connector for Apache Spark](https://github.com/apache/phoenix-connectors/tree/master/phoenix5-spark3#configuring-spark-to-use-the-connector) that documents how one can perform OLAP on Apache Phoenix in Java/Scala using Spark.

## Footnote

This article is written by Abhey Rana and is meant to bridge the missing documentation gap in the official documentation of Apache Phoeni's connector for Apache Spark. PR for adding the missing documentation is already open in the community.

All the code expalined in this article is publicly available in the [phoenix-spark-connector-demo](https://github.com/Abhey/phoenix-spark-connector-demo) GitHub repository. Please feel free to create GitHub issues on the same in case you have any doubts.

--------------------------------------------------------------------------------------------

*Enjoyed reading this article? Leave a comment below to let me know.*
