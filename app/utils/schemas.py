from pyspark.sql.types import StructType, StructField, LongType

raw_data_schema = StructType([
    StructField("X1", LongType(), True),
    StructField("X2", LongType(), True),
    StructField("X3", LongType(), True),
    StructField("X4", LongType(), True),
    StructField("X5", LongType(), True),
    StructField("X6", LongType(), True),
    StructField("X7", LongType(), True),
    StructField("X8", LongType(), True),
    StructField("X9", LongType(), True),
    StructField("X10", LongType(), True),
    StructField("X11", LongType(), True),
    StructField("X12", LongType(), True),
    StructField("X13", LongType(), True),
    StructField("X14", LongType(), True),
    StructField("X15", LongType(), True),
    StructField("X16", LongType(), True),
    StructField("X17", LongType(), True),
    StructField("X18", LongType(), True),
    StructField("X19", LongType(), True),
    StructField("X20", LongType(), True),
    StructField("X21", LongType(), True),
    StructField("X22", LongType(), True),
    StructField("X23", LongType(), True),
    StructField("Y", LongType(), True)
])