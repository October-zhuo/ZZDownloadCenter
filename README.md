# ZZDownloadCenter
To do download task in a safe and easy way for iOS developer in Objective-C.

## 介绍
这是一个用OC实现的下载框架。用户传入需要下载资源的URL，该框架就会自行在异步线程进行下载，下载完成后以block回调的方式将资源所在的沙盒地址返回给用户。如果下载过程中出现错误，错误也会以回调的形式返回给用户。另外，该框架是通过单独创建下载session，并且使用`backgroundSessionConfigurationWithIdentifier:`配置session。即使APP被切换到后台，下载任务也依然能够运行。最后，该框架会在下载前查询本地是否已经存在要下载的资源，如果有就直接返回资源的本地路径，避免多次重复下载。
## 目录介绍
该项目主要有两部分组成：`ZZDownloadCenterDemo`包括下载框架和演示demo；`NodeForLoad`是用nodeJS实现的后台程序，主要目的是配合下载demo完成下载框架的测试。

## 使用方法
### 测试框架
1. 打开终端，切换至`NodeForLoad`目录，输入`node app.js`即可在本机上开启后台服务。
2. 此时访问`http://localhost:9000/index`，就可以上传文件，这些上传的文件就是供ZZDownloadCenter框架下载的文件。
3. 打开`ZZDownloadCenterDemo`中的`ZZDownloadCenterDemo.xcworkspace`就可以看到在web端上传的文件列表，点击进入就可以测试下载框架。


### 使用框架
* `pod ‘ZZDownloadCenter’`
* 在项目的`APPDelegate.m`中，粘贴以下代码

```- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    NSURLSession *session = [ZZDownloadSession backgroundSession];
    NSLog(@"%@",session);
    [[ZZDownloadSessionHelper sharedHelper] cacheCompletionHandler:completionHandler withID:identifier];
}
```

* 在需要进行下载任务的地方调用下载方法，如下

```
 [[ZZDownloadCenter defaultCenter] downloadWithURL:[NSURL URLWithString:self.urlLabel.text] configuration:nil progres:^(float progress) {
        NSLog(@"%f",progress);
    } completion:^(NSURL *localURL, NSError *error) {
        if (error) {
            NSLog(@"download error -=-=-=--=-:%@",error);
        }else{
            NSLog(@"Where amazing happens! %@",localURL.absoluteString);
        }
    }];
```


