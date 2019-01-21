import Cocoa
import CreateML
import NaturalLanguage

//原始数据
let filePath = Bundle.main.path(forResource: "MessageData", ofType: "json")
let data = try MLDataTable(contentsOf: URL(fileURLWithPath:filePath!))

//拆解数据，按照8:2的比例将语料库分为两个数据集，一个为训练集，一个为测试集
let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)

//训练
let sentimentClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "label")

//评估
let evaluationMetrics = sentimentClassifier.evaluation(on: testingData)
let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100

//预测
let sentimentPredictor = try NLModel(mlModel: sentimentClassifier.model)
sentimentPredictor.predictedLabel(for: "固话、宽带、移网用户均有机会得全年免账单")

//导出模型
let metaData = MLModelMetadata(author: "yue", shortDescription: "无用短信过滤", license: nil, version: "1.0", additional: nil)
//在桌面生成一个名为 Filter.mlmodel 的模型
try sentimentClassifier.write(toFile: "~/Desktop/Filter.mlmodel", metadata: metaData)
