//
//  WBNetworkManager.swift
//  WBNetwork
//
//  Created by zhaowenbin on 2021/1/29.
//

import UIKit

/// 网络请求封装类
class WBNetworkManager: NSObject {
    
    /// 成功回调闭包
    typealias successCallback = (([String: Any], URLRequest?, URLResponse?) -> ())

    /// 失败回调闭包
    typealias failureCallback = ((Error?, URLRequest?, URLResponse?) -> ())
    
    /// 单例
    static let share = WBNetworkManager()
    
    /// baseURL
    private var baseURL = ""
    
    /// 网络请求类型
    struct WBNetworkType {
        
        static let get = WBNetworkType(rawValue: "GET")
        static let post = WBNetworkType(rawValue: "POST")
        
        fileprivate let rawValue: String
        fileprivate init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
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
}

// MARK:- 普通网络请求

extension WBNetworkManager {
    
    /// 普通网络请求实现
    /// - Parameters:
    ///   - url: url
    ///   - networkType: 请求类型
    ///   - headers: 请求头
    ///   - params: 参数
    ///   - body: body
    ///   - success: 成功回调
    ///   - failure: 失败回调
    private func sendRequest(url: String,
                         networkType: WBNetworkType,
                         headers: [String: String]?,
                         params: [String: String]?,
                         body: [String: Any]?,
                         success: @escaping successCallback,
                         failure: @escaping failureCallback) {
        
        /****************************配置断言**********************************/
        
        assert(url.isEmpty, "传入的url为空")
        
        /****************************开始配置request***************************/
        
        // 生成urlrequest
        var request = URLRequest(url: self.configParams(url: baseURL+url, params: params),
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 60.0)
        
        // 配置请求类型
        request.httpMethod = networkType.rawValue
        
        // 配置Header
        if headers != nil {
            for (key, value) in headers! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // 配置body内容
        if body != nil {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body!, options: .fragmentsAllowed)
        }
        
        /****************************开始配置task******************************/
        
        URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            
            self.handleClosure(data: data,
                               response: response,
                               error: error,
                               request: request,
                               success: success,
                               failure: failure)
            
        }.resume()
    }
}

// MARK:- 上传

extension WBNetworkManager {
    private func sendUploadRequest(url: String,
                                   headers: [String: String]?,
                                   name: String?,
                                   fileName: String?,
                                   mimeType: String?,
                                   fileData: Data?,
                                   filePathURL: String?,
                                   success: @escaping successCallback,
                                   failure: @escaping failureCallback) {
        
        /****************************配置断言**********************************/
        
        assert(url.isEmpty, "传入的url为空")
        assert(fileData == nil && filePathURL == nil, "传入文件为空, 请检查fileData或filePathURL")
        assert(name == nil, "传入name为空")
        assert(fileName == nil, "传入fileName为空")
        assert(mimeType == nil, "传入mimeType为空")
        
        /****************************开始配置request***************************/
        
        // 配置request
        var request = URLRequest(url: URL(string: url)!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 60.0)
        // 配置请求类型
        request.httpMethod = "POST"
        
        // 配置body
        let params = ["name": name!,
                      "fileName": fileName!,
                      "mimeType": mimeType!]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .fragmentsAllowed)
        
        // 配置Header
        if headers != nil {
            for (key, value) in headers! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        /****************************开始配置task******************************/
        
        /// 网络请求回调的闭包
        /// - Parameters:
        ///   - data: data
        ///   - response: response
        ///   - error: error
        /// - Returns: void
        func uploadCompletionHandler(data: Data?, response: URLResponse?, error: Error?) -> Void {
            self.handleClosure(data: data,
                               response: response,
                               error: error,
                               request: request,
                               success: success,
                               failure: failure)
        }
        
        if fileData != nil {
            // 用文件data上传
            URLSession.shared.uploadTask(with: request,
                                                      from: fileData,
                                                      completionHandler: uploadCompletionHandler).resume()
        } else {
            // 用文件路径方式上传
            URLSession.shared.uploadTask(with: request,
                                                      fromFile: URL(fileURLWithPath: filePathURL!),
                                                      completionHandler: uploadCompletionHandler).resume()
        }
    }
}

// MAKR:- 下载

extension WBNetworkManager {
    
}

// MARK:- 统一处理网络请求的信息

extension WBNetworkManager {
    
    /// 处理网络请求的配置信息
    /// - Parameters:
    ///   - url: url
    ///   - params: params
    /// - Returns: 处理后的url
    private func configParams(url: String, params: [String: String]?) -> URL {
        
        // 配置参数
        // 如果传了params参数, 无论是GET还是POST, 都做处理, 因为有时候是POST请求有body, 又有参数的情况
        // 所以只要传了params, 就做处理
        if params != nil {
            var components = URLComponents(string: url)
            for (key, value) in params! {
                components?.queryItems?.append(URLQueryItem(name: key, value: value))
            }
            let query = components?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            components?.percentEncodedQuery = query
            return (components?.url)!
        } else {
            return URL(string: url)!
        }
    }
    
    /// 网络请求返回结果统一处理
    /// - Parameters:
    ///   - data: data
    ///   - response: response
    ///   - error: error
    ///   - request: request
    ///   - success: success
    ///   - failure: failure
    private func handleClosure(data: Data?,
                               response: URLResponse?,
                               error: Error?,
                               request: URLRequest,
                               success: successCallback,
                               failure: failureCallback) {
        if error != nil {
            failure(error, request, response)
            return
        }
        
        guard data != nil else {
            return
        }
        guard response != nil else {
            return
        }
        
        guard let result = try? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) else {
            return
        }
        
        success(result as! [String: Any], request, response)
    }
}
