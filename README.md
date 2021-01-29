# WBNetworkManager
Swift 原生网络请求封装类，包含普通数据请求、上传文件、下载文件

⚠️还在完善中, 谨慎使用.

## 用途
在swift中, 一般使用 `Moya` 和 `Alamofire` 作为网络请求框架进行封装, 本框架使用原生URLSession封装成简单的网络请求库, 避免太多功能用不上, 引入第三方库太多的问题.

## 用法
下载后将 `WBNetworkManager` 文件夹拖入项目即可, 只有一个文件, 尽量满足需求的同时, 简洁处理.

目前只有两个Public API, 调用时直接用类名.sendRequest即可.
``` swift
/// 普通网络请求
/// 没有的参数传nil
/// - Parameters:
///   - url: url
///   - networkType: 网络请求类型
///   - headers: 请求头
///   - params: 参数
///   - body: body
///   - success: 成功回调
///   - failure: 失败回调
public class func sendRequest(url: String,
                          networkType: WBNetworkType,
                          headers: [String: String]?,
                          params: [String: String]?,
                          body: [String: Any]?,
                          success: @escaping successCallback,
                          failure: @escaping failureCallback) {
    WBNetworkManager.share.sendRequest(url: url,
                            networkType: networkType,
                            headers: headers,
                            params: params,
                            body: body,
                            success: success,
                            failure: failure)
}
```

``` swift
/// 上传文件网络请求
/// 没有的参数传nil
/// - Parameters:
///   - url: url
///   - headers: 请求头
///   - name: 参数
///   - fileName: 文件名带后缀
///   - mimeType: 文件类型
///   - fileData: 文件data 和👇filePathURL二选一
///   - filePathURL: 文件filePath 和👆fileData二选一
///   - success: 成功回调
///   - failure: 失败回调
public class func sendUploadRequest(url: String,
                               headers: [String: String]?,
                               name: String?,
                               fileName: String?,
                               mimeType: String?,
                               fileData: Data?,
                               filePathURL: String?,
                               success: @escaping successCallback,
                               failure: @escaping failureCallback) {
    WBNetworkManager.share.sendUploadRequest(url: url,
                                             headers: headers,
                                             name: name,
                                             fileName: fileName,
                                             mimeType: mimeType,
                                             fileData: fileData,
                                             filePathURL: filePathURL,
                                             success: success,
                                             failure: failure)
}
```
