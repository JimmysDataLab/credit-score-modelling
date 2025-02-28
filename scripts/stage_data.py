from ucimlrepo import fetch_ucirepo
from pyspark.sql import SparkSession
from pyspark.sql.functions import monotonically_increasing_id
from pyspark.sql.types import StructType, StructField, LongType
import os
from utils.schemas import raw_data_schema




def write_data(train_path, test_path, spark):
    # Ensure absolute paths
    train_path = os.path.abspath(train_path)
    test_path = os.path.abspath(test_path)
    
    print(f"Writing to absolute paths:\nTrain: {train_path}\nTest: {test_path}")
    
    # fetch dataset 
    default_of_credit_card_clients = fetch_ucirepo(id=350) 
    X = spark.createDataFrame(default_of_credit_card_clients.data.features)
    y = spark.createDataFrame(default_of_credit_card_clients.data.targets)

    # Print initial data info
    print(f"Features shape: {X.count()} rows")
    print(f"Targets shape: {y.count()} rows")

    # combine X and y
    X = X.withColumn("id", monotonically_increasing_id())
    y = y.withColumn("id", monotonically_increasing_id())
    df = X.join(y, on="id", how="inner").drop("id")
    
    total_count = df.count()
    print(f"Combined dataset size: {total_count} rows")

    train, test = df.randomSplit([.7,.3], seed=42)
    
    # Get counts before writing
    train_count = train.count()
    test_count = test.count()
    print(f"Split sizes - Train: {train_count}, Test: {test_count}")

    if train_count == 0 or test_count == 0:
        raise ValueError("Train or test dataset is empty after split")
        
    # Ensure the directory exists
    os.makedirs(os.path.dirname(train_path), exist_ok=True)
    os.makedirs(os.path.dirname(test_path), exist_ok=True)

    train.printSchema()
    test.printSchema()
    
    # Write with coalesce instead of repartition for smaller files
    train.coalesce(1).write.mode("overwrite").parquet(train_path)
    test.coalesce(1).write.mode("overwrite").parquet(test_path)
    
    # Verify files exist after writing
    if not os.path.exists(train_path) or not os.path.exists(test_path):
        raise FileNotFoundError("Failed to write parquet files")
        
    print(f"Files successfully written to disk")
    print(f"Train directory exists: {os.path.exists(train_path)}")
    print(f"Test directory exists: {os.path.exists(test_path)}")

def read_data(train_path, test_path, spark):
    print(f"Attempting to read from:\nTrain: {train_path}\nTest: {test_path}")
    
    if not os.path.exists(train_path):
        raise FileNotFoundError(f"Train path does not exist: {train_path}")
    if not os.path.exists(test_path):
        raise FileNotFoundError(f"Test path does not exist: {test_path}")
        
    # List contents of directories
    print(f"Train directory contents: {os.listdir(train_path)}")
    print(f"Test directory contents: {os.listdir(test_path)}")
    
    try:
        # Read with predefined schema
        train = spark.read.schema(raw_data_schema).parquet(train_path)
        test = spark.read.schema(raw_data_schema).parquet(test_path)
        
        print("Schema of loaded train data:")
        train.printSchema()
        
        # Verify the data was read successfully
        train_count = train.count()
        test_count = test.count()
        
        print(f"Initial read - Train count: {train_count}, Test count: {test_count}")
        
        if train_count == 0 or test_count == 0:
            raise ValueError("Read data is empty")
            
        print(f"Train data read: {train_count} rows")
        print(f"Test data read: {test_count} rows")
        
        return train, test
    except Exception as e:
        print(f"Error reading parquet files: {str(e)}")
        raise


if __name__=="__main__":
    print("import this package")