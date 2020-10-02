package org.apache.spark.examples.ml
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.classification.{RandomForestClassificationModel, RandomForestClassifier}
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
import org.apache.spark.ml.feature.{IndexToString, StringIndexer, VectorIndexer}
import org.apache.spark.sql.SparkSession
import org.apache.spark.ml.feature.VectorAssembler
import org.apache.spark.ml.feature.StringIndexer 

//
val spark = SparkSession.builder.appName("RandomForestClassifierExample").getOrCreate()

//
val df= spark.read.option("header", "true").option("inferSchema","true")csv("/home/karen/Escritorio/Algoritmos/Datos.csv")

//
df.columns 
df.printSchema () 
df.head (686) 
df.describe (). show () 


val labelIndexer = new StringIndexer().setInputCol("Faults").setOutputCol("indexedLabel").fit(df)
val df1= labelIndexer.transform(df).drop("Faults").withColumnRenamed("indexedLabel", "label")
df1.describe().show()
//
val Maintenanceequipment = new StringIndexer().setInputCol("Maintenance equipment").setOutputCol("Maintenance").fit(df1)
val data1 = Maintenanceequipment.transform(df1).drop("Maintenance equipment").withColumnRenamed("Maintenance", "Maintenance equipment")
data1.describe().show() 
//
val assembler = new VectorAssembler().setInputCols(Array("Machine number","Maintenance equipment","Supplier","Time (days)")).setOutputCol("features")
val  data = assembler.transform(data1)
data.describe().show() 
//
val labelIndexer = new StringIndexer().setInputCol("label").setOutputCol("indexedLabel").fit(data)

// 
val featureIndexer = new VectorIndexer().setInputCol("features").setOutputCol("indexedFeatures").setMaxCategories(2).fit(data)

// We divide the dataframe into 70% for training and 30% for testing
val Array(trainingData, testData) = data.randomSplit(Array(0.7, 0.3))

// Train a RandomForest model.
val rf = new RandomForestClassifier().setLabelCol("indexedLabel").setFeaturesCol("indexedFeatures").setNumTrees(10)

// Convert indexed labels back to original labels.
val labelConverter = new IndexToString().setInputCol("prediction").setOutputCol("predictedLabel").setLabels(labelIndexer.labels)

// we create a pipeline with pipeline
val pipeline = new Pipeline().setStages(Array(labelIndexer, featureIndexer, rf, labelConverter))

// We train the model
val model = pipeline.fit(trainingData)

// We transform predictions
val predictions = model.transform(testData)

// Select example rows to display.
predictions.select("predictedLabel", "label", "features").show(686)

// We select the labels that will be shown in the prediction
val evaluator = new MulticlassClassificationEvaluator().setLabelCol("indexedLabel").setPredictionCol("prediction").setMetricName("accuracy")
val accuracy = evaluator.evaluate(predictions)
// We print the model accuracy
println(s"Test Error = ${(1.0 - accuracy)}")
// we print the model
val rfModel = model.stages(2).asInstanceOf[RandomForestClassificationModel]
println(s"Learned classification forest model:\n ${rfModel.toDebugString}")