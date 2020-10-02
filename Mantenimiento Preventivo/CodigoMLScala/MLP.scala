//Paso 1: carga de paquetes y API necesarios
import org.apache.spark.sql.types.IntegerType
import org.apache.spark.ml.evaluation.MulticlassClassificationEvaluator
import org.apache.spark.ml.classification.MultilayerPerceptronClassifier
import org.apache.spark.sql.SparkSession
import org.apache.spark.ml.feature.StringIndexer 
import org.apache.spark.ml.feature.VectorAssembler

//crear una sesión de Spark
val spark = SparkSession.builder.appName("MultilayerPerceptronClassifierExample").getOrCreate()


//carga y analiza el conjunto de datos
val df = spark.read.option("header", "true").option("inferSchema","true")csv("/home/karen/Escritorio/Algoritmos/Datos.csv")

// Visualización datos
df.columns 
df.printSchema () 
df.head (5) 
df.describe (). show () 

// categorizamos Maintenance equipment para poderla utilizar en el modelo
val Maintenanceequipment = new StringIndexer().setInputCol("Maintenance equipment").setOutputCol("Maintenance").fit(df)
val df1 = Maintenanceequipment.transform(df).drop("Maintenance equipment").withColumnRenamed("Maintenance", "Maintenance equipment")
df1.describe().show() 

//renombramos la variable indexedLabel
val labelIndexer = new StringIndexer().setInputCol("Faults").setOutputCol("indexedLabel").fit(df1)
val indexed = labelIndexer.transform(df1).drop("Faults").withColumnRenamed("indexedLabel", "label")
indexed.describe().show() 

//Vectorizamos todas las caracteristicas menos la que queremos predecir
//Ensamblar y agregar la variable features
val assembler = new VectorAssembler().setInputCols(Array("Machine number","Maintenance equipment","Supplier","Time (days)")).setOutputCol("features")
val  features = assembler.transform(indexed)

//indexar los datos,ajustar al conjunto de datos completo para incluir todas las etiquetas en el índice. 
val labelIndexer = new StringIndexer().setInputCol("label").setOutputCol("indexedLabel").fit(indexed)
println(s"Found labels: ${labelIndexer.labels.mkString("[", ", ", "]")}")
features.show()

//preparacion de conjunto de prueba
 val splits = features.randomSplit(Array(0.6, 0.4), seed = 1234L)
 val train = splits(0)
 val test = splits(1)

//capas de la red neuronal  4 caracteristicas, capas ocultas, 2 clases
val layers = Array[Int](4, 4, 1, 2)

//crear el entrenador del modelo 
val trainer = new MultilayerPerceptronClassifier().setLayers(layers).setBlockSize(128).setSeed(1234L).setMaxIter(100)  

//entrenar modelo
val model = trainer.fit(train)


//calcular presicion de conjunto de prueba comparando model resultados con test
val result = model.transform(test)

//evaluar rendimiento de predicion de medicion
val predictionAndLabels = result.select("prediction", "label")
predictionAndLabels.show(685)

// evaluar la exactititud del modelo
val evaluator = new MulticlassClassificationEvaluator().setMetricName("accuracy")
println(s"Test set accuracy = ${evaluator.evaluate(predictionAndLabels)}")

spark.stop()