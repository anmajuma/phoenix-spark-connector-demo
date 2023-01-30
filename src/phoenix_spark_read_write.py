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

# Write DataFrame to the Phoenix Table.
df.write.format("phoenix").option("table", "india_population").option("zkUrl", "localhost:2181").mode("append").save()

# Read data from Phoenix Table and store it in a DataFrame.
df = ss.read.format("phoenix").option("table", "india_population").option("zkUrl", "localhost:2181").load()
df.show()

# Data filtering approach - 1
df.filter((df.CITY == "Mumbai") | (df.STATE == "West Bengal")).show()

# Data filtering approach - 2
df.createOrReplaceTempView("india_population_temp")
ss.sql("SELECT * FROM india_population_temp WHERE CITY='Mumbai' OR STATE='West Bengal'").show()
