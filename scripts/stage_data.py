from ucimlrepo import fetch_ucirepo
from pyspark.sql import SparkSession
from pyspark.sql.functions import monotonically_increasing_id
import os




def main():


    train_path = os.environ.get("TRAIN_PATH")
    test_path = os.environ.get("TEST_PATH")
    spark_master = os.environ.get("SPARK_MASTER_URL")
    SEEDS = [1,2,4,56,42,75,12,56,9]

    spark = SparkSession.builder \
        .appName("Stage-Data") \
        .master(spark_master) \
        .getOrCreate()

    # fetch dataset 
    default_of_credit_card_clients = fetch_ucirepo(id=350) 
    X = spark.createDataFrame(default_of_credit_card_clients.data.features)
    y = spark.createDataFrame(default_of_credit_card_clients.data.targets)

    # combine X and y
    X = X.withColumn("id", monotonically_increasing_id())
    y = y.withColumn("id", monotonically_increasing_id())
    df = X.join(y, on="id", how="inner").drop("id")

    for seed in SEEDS:
        # if not os.path.exists(os.path.join(train_path,str(seed))) \
        #                         and not os.path.exists(os.path.join(test_path,str(seed))):
        train, test = df.randomSplit([.7,.3], seed=seed)
        train.write.mode("overwrite").parquet(os.path.join(train_path,str(seed)))
        test.write.mode("overwrite").parquet(os.path.join(test_path,str(seed)))

    spark.stop()

if __name__=="__main__":
    main()