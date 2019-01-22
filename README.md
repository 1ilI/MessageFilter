# 短信过滤-MessageFilter
一款基于机器学习（Core ML）的专属于你的短信过滤应用

<div align="center"> 
<img alt="message-filter" src="https://raw.githubusercontent.com/1ilI/1ilI.github.io/master/resource/2018-12/message-filter.png" width="320px"/>
<p>信息中的「未知与过滤信息」</p>
</div>

## 背景
现在手机短信最大的作用可能就是接收验证码了吧，可是类似这样的短信

`【xx银行】经鉴定，您的资质良好，完善信息即可申请我行高额信用卡，额度高，点xxxx办理，退订回T`<br/>
`【xxx安】尊贵的x安客户，为您提供专属应急金，最高5万最快3分钟办理，更有最高300元话费奖励，戳xxxx ，TD退订`

不知你有没有收到过，反正我是经常收 -_-# 还有各种各样的广告短信，每天都有，不绝于耳。

而且时间长不删，手机上短信就是99+，和正常的短信混在一块，删的时候可是烦的一
<div align="center"> <img alt="99+" src="https://raw.githubusercontent.com/1ilI/1ilI.github.io/master/resource/2018-12/message-99more.png"/></div>

不过好在还是有解决方法的，就是在信息中打开`未知与过滤信息`，这样就会把符合一定规则的新信息放到这一栏，虽然还是能收得到，还是有角标，但有的总比没有的强吧😂

对于这个规则的实现或补充，可以用第三方软件，像`xx手机管家/助手`等。当然，我们也可以自己实现。本文就是利用 `Core ML` 来生成这一规则，进而来实现过滤短信的。

## Core ML
iOS11 的时候苹果就已经出了 `Core ML`，它可以用一个模型（trained model）来预测你输入的新内容是什么，并且支持图像视觉分析，自然语义处理 🐂的一。[详见官方对 Core ML 的介绍](https://developer.apple.com/documentation/coreml?language=objc)

那么这个神奇的模型怎么来的呢，苹果官方有提供一些[模型](https://developer.apple.com/machine-learning/build-run-models/)可供大家下载使用，此外，还有其他的大学、学术/研究机构发布的一些模型和训练数据。但是，对于我等小白来说，想要自己从头训练，生成模型，还是需要好好研究一番的。

## Create ML
而现在，随着 iOS12 的发布，Core ML 也升级到了 2，同时为了方便模型的生成，`Create ML`也随之应运而生。不过这是基于 Mac 系统上的，要求 `macOS 10.14+` [详见官网](https://developer.apple.com/documentation/createml)

对于本文，我们只用了一个简单的小功能，创建文本分类器模型，拉个图

![creating_a_text_classifier_model_1](https://docs-assets.developer.apple.com/published/e64757cc2b/d3084220-dafe-4388-9c42-955e35bc54b4.png)

![creating_a_text_classifier_model](https://docs-assets.developer.apple.com/published/145857b702/e569d02f-19a9-48fd-a9d5-aa8d3a662b98.png)

我们要做的就是给一段文本打标签，标记好这段文本是什么类型的，那段文本是什么类型的，然后把这些原始数据，可以是`JSON`也可以是`CSV`格式的数据导入进去，剩下的交给 Create ML 就可以了。

对于文初的那种短信，我们可以标记成`过滤`，而对于需要正常保留提醒的短信，我们可以标记成`正常`。比如像这样的：

![message-filter-json](https://raw.githubusercontent.com/1ilI/1ilI.github.io/master/resource/2018-12/message-filter-json.png)

多准备点这样的数据，它们就是你的语料库，语料越多，预测的越准确。


### 导入原始数据

又到了喜闻乐见的敲代码环节了，话不多说，上代码

```swift
//导入原始数据
let filePath = Bundle.main.path(forResource: "MessageData", ofType: "json")
let data = try MLDataTable(contentsOf: URL(fileURLWithPath:filePath!))
```

### 训练模型

```swift
//拆解数据，按照8:2的比例将语料库分为两个数据集，一个为训练集，一个为测试集
let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)
//训练
let sentimentClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "label")
```

### 评估准确性

```swift
//评估
let evaluationMetrics = sentimentClassifier.evaluation(on: testingData)
let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100
```

如果评估的准确性不高可能你数据源少了 = =  ，另附[提高模型的准确性](https://developer.apple.com/documentation/createml/improving_your_model_s_accuracy)

### 导出 Core ML 模型

```swift
//导出模型
let metaData = MLModelMetadata(author: "yue", shortDescription: "无用短信过滤", license: nil, version: "1.0", additional: nil)
//在桌面生成一个名为 Filter.mlmodel 的模型
try sentimentClassifier.write(toFile: "~/Desktop/Filter.mlmodel", metadata: metaData)
```

### 使用模型进行预测

```swift
//预测
let sentimentPredictor = try NLModel(mlModel: sentimentClassifier.model)
sentimentPredictor.predictedLabel(for: "经鉴定，您的资质良好，完善信息即可申请我行高额信用卡")
```

## mlmodel 的使用
对于 Core ML 模型的使用，把上面生成的`Filter.mlmodel`，直接拖进工程里就可以了，系统会自动生成一个同名的类，里面有`XXX`（文件名）这个类，还有`XXXInput`和`XXXOutput`这两个输入输出类。他们在这里：
![filter-class](https://raw.githubusercontent.com/1ilI/1ilI.github.io/master/resource/2018-12/filter-class.png)

因为我们的这个模型比较简单，就是预测一段文本是属于`正常`的一类，还是`过滤`的一类。所以，它的输入值就是一串文本，输出值就是`正常`或`过滤`，我们直接调用类的实体方法`predictionFromText: error:`就好了。

```objc
/**
 判断输入的文本是属于哪一类
 @param message 输入的文本
 @return "正常" 或 "过滤"
 */
+ (NSString *)judgeTypeWithMessage:(NSString *)message {
    Filter *filter = [[Filter alloc] init];
    NSError *error = nil;
    FilterOutput *output = [filter predictionFromText:message error:&error];
    NSString *outputLabel = output.label;
    if (!error && outputLabel.length) {
        return outputLabel;
    }
    else {
        NSLog(@"CoreML输出出错--->%@",error);
        return nil;
    }
}
```

## 短信过滤
而短/彩信过滤，主要用了 [SMS and Call Reporting](https://developer.apple.com/documentation/sms_and_call_reporting?language=objc) 里的 [SMS and MMS Message Filtering](https://developer.apple.com/documentation/sms_and_call_reporting/sms_and_mms_message_filtering?language=objc)

<div align="center"> <img alt="filter" src="https://docs-assets.developer.apple.com/published/896e483792/bffa422c-8e24-4c8b-a294-3838471d2049.png"/></div>

其实它就是一个`Extension`，在工程里新建一个`Target`，然后在 `Application Extension` 找到 `Message Filter Extension` ，填好必要信息后，`MessageFilterExtension` 这个类就自动构建好了，这里面就是我们短信过滤的核心内容了。
![create-message-filter](https://raw.githubusercontent.com/1ilI/1ilI.github.io/master/resource/2018-12/create-message-filter.png)

因为本文是基于本地的模型，预测短信类型来进行拦截的，所以直接在 `MessageFilterExtension.m` 中，实现 `offlineActionForQueryRequest :` 这个方法就可以了。

```objc
- (ILMessageFilterAction)offlineActionForQueryRequest:(ILMessageFilterQueryRequest *)queryRequest {
    //queryRequest.messageBody 就是短信文本内容
    //如果预测短信内容是需要 过滤 的话，则返回 ILMessageFilterActionFilter
    NSString *label = [FilterModel judgeTypeWithMessage:queryRequest.messageBody];
    if ([label isEqualToString:@"过滤"]) {
        return ILMessageFilterActionFilter;
    }
    return ILMessageFilterActionNone;
}
```

## 开启短信过滤
`Extension`构建完毕，直接真机运行吧。主程序里啥都没有，但是打开<br/>【设置】-->【信息】-->【未知与过滤信息】<br/>你就会看到【短信过滤】这一项，里面有我们刚刚新建的扩展，显示的名字是该扩展的`Display Name`

打开或勾选那一项，这个专属于你自己的短信过滤功能就开启啦，以后但凡有符合你规则的垃圾短信都会被放到「未知与过滤信息」这一栏。
<div align="center"> <img alt="open-filter" src="https://raw.githubusercontent.com/1ilI/1ilI.github.io/master/resource/2018-12/open-filter.png" width="320px"/></div>

当一个号码被过滤后，以后该号码发的所有信息都将会被放在过滤这一栏，取消的方式是：

1. 回应短信或彩信三次
2. 将发件人添加到“通讯录”
3. 删除该号码下的全部短信，下次再来就会重新预测，看是否过滤

手机上【关于短信过滤与隐私】上面也有介绍。

## 完善应用功能
这个短信过滤的正确率是由我们训练的那个模型决定的，而模型准预测确度的提高是需要不断喂养大量数据的，只有通过不断的学习更多的数据，才能不断的完善它的准确度，这是一个长期的过程。

然而，当前我们这个模型一旦生成后，就无法改变了，也就是说每一次提高过滤的正确率，就需要新增一次数据、导出一次模型、打包一次 APP 的。

对于导出模型，打包 APP ，这个没的说，现阶段只能这样来。

立个 flag 吧，希望哪天苹果可以直接在手机上训练模型，然后直接使用，以现在的 A12 处理器，问题应该不大吧。或者说来一种动态更新 mlmodel 模型的方式，这样就不需要再重新打包了。

### 数据收集
现阶段，能做的好像也就只剩数据收集了(￣▽￣)

那么，做一个数据存储吧，保存一下短信和其分类，从短信里复制，然后粘贴，标记类别<br/>
再做一个查看吧，好看看一共有多少数据了<br/>
对了，有的数据不想要了怎么办，那再做个删除吧<br/>
还有，分类标错了怎么办，那再加个分类修改吧<br/>

好了，增删改查来一套😂，emm 好像还差一个数据导出，不然存了这些数据给谁用呢。那导出都有了，导入也不能少呀，强行增加需求 = =
<div align="center"> <img alt="qiao-code" src="https://raw.githubusercontent.com/1ilI/1ilI.github.io/master/resource/2018-12/qiao-code.png"/></div>

## 完成
我大致实现了这些功能，[点此下载](https://codeload.github.com/1ilI/Y_PickerView/zip/master)

该工程没有包含我训练的模型，要想运行使用，<br/>
**先把自己的 mlmodel 训练好并导入进去，然后就可以了**

<div align="center"> <img alt="message-filter-demo" src="https://raw.githubusercontent.com/1ilI/1ilI.github.io/master/resource/2018-12/message-filter-demo.gif"/></div>

## [查看更多](https://1ili.github.io/)
