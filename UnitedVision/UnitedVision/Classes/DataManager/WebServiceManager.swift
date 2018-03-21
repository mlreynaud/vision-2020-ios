//
//  WebServiceManager.swift
//  UnitedVision
//
//  Created by Agilink on 06/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

let kNetworkErrorMessage = "App encountered a Network connection problem. Please try again shortly."

typealias CompletionHandlerClosureType = (_ data: Data?, _ error: NSError?) -> ()
typealias DownloadHandlerClosureType = (_ filepath: URL?, _ error: NSError?) -> ()

var serviceCompletionHandler : CompletionHandlerClosureType?

class WebServiceManager: NSObject, URLSessionDelegate {
    
    static let sharedInstance = WebServiceManager()
    fileprivate override init() {}
    
    let defaultSession: URLSession = URLSession.shared
    
    
    //    class func defaultSession() -> NSURLSession  {
    //
    //        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    //        let session = NSURLSession(configuration: configuration, delegate: self as? NSURLSessionDelegate, delegateQueue: nil)
    //        return session
    //    }
    
    class func getRequest(_ service: String) -> URLRequest
    {
        let urlString = kServerUrl + service
        return WebServiceManager.getRequest(url:urlString) as URLRequest
    }
    
    class func getRequest(url urlString: String) -> NSMutableURLRequest
    {
        let request = WebServiceManager.createRequest(urlString, forMethod: "GET")
        return request
    }
    
    class func postRequest (service serviceString : String, withPostString postString: String ) -> URLRequest
    {
        let urlString = kServerUrl + serviceString
        return WebServiceManager.postRequest(url:urlString, withPostString: postString) as URLRequest
    }
    
    class func postRequest (service serviceString : String, withPostDict params: Dictionary <String, Any> ) -> NSMutableURLRequest
    {
        let urlString = kServerUrl + serviceString
//        let postData = postString.data(using: String.Encoding.utf8)
//        let postLength = String("\(String(describing: postData?.count))")
        
        let request =  WebServiceManager.createRequest(urlString, forMethod: "POST")
//        request.setValue(postLength, forHTTPHeaderField:"Content-Length")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
       
        return request
    }
    
    class func postRequest (url urlString : String, withPostString postString: String ) -> NSMutableURLRequest
    {
        let postData = postString.data(using: String.Encoding.utf8)
        let postLength = String("\(String(describing: postData?.count))")
        
        let request =  WebServiceManager.createRequest(urlString, forMethod: "POST")
        request.setValue(postLength, forHTTPHeaderField:"Content-Length")
        
        request.httpBody = postData
        
        return request
    }
    
    class func createRequest(_ urlString: String, forMethod httpMethod:String) -> NSMutableURLRequest
    {
        let request =  NSMutableURLRequest(url: URL(string: urlString)! as URL)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.timeoutInterval = 60.0
        //        request.cachePolicy = .returnCacheDataElseLoad
        
        if (DataManager.sharedInstance.isLogin)
        {
            let token = DataManager.sharedInstance.authToken
            request.setValue(token, forHTTPHeaderField:"Authorization")
        }
        
        return request
    }
    
    class func sendRequest(_ request: URLRequest, completionHandler handler: @escaping CompletionHandlerClosureType )
    {
        printWebRequest(request: request)
        
        serviceCompletionHandler = handler
        
        if (UIUtils.isConnectedToNetwork() == false){
            serviceCompletionHandler!(nil, NSError(domain: kNetworkErrorMessage, code: 0, userInfo: nil))
            return
        }
        
        let startDate = Date();
        print("StartDate- \(startDate)")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dataTask :URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            
            let endDate = NSDate()
            print("End date- \(endDate)")
            
            let timeInterval = endDate.timeIntervalSince(startDate as Date)
            print("App response time- \(timeInterval)")
            
            WebServiceManager.printResponse(response: data)
            
            DispatchQueue.main.async {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                    else {
                        print("error: not a valid http response")
                        serviceCompletionHandler!(nil, error as NSError?)
                        return
                }
                
                if let auth = httpResponse.allHeaderFields["Authorization"] as? String {
                    // use X-Dem-Auth hereA
                        DataManager.sharedInstance.authToken = auth
                    
                        AppPrefData.sharedInstance.authToken = auth;
                        AppPrefData.sharedInstance.saveAllData()
                    
                        print (auth);
                }
                
//                guard let rawString = String(data: receivedData, encoding: .utf8) else {
//                    return
//                }
////                let newString = aString.replacingOccurrences(of: "\", with: "+")
////                let escapedString =  rawString.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil)
//
//                let string = rawString.unescaped
//                let escapedString = rawString.replacingOccurrences(of: "\\\"", with: "", options: .literal, range: nil)
//
////                let escapedString = rawString.stringByReplacingOccurrencesOfString("\"", withString: "", options: .literalSearch, range: nil)
//                let jsonData = string.data(using: .utf8)

                //let httpResponse : NSHTTPURLResponse = response as! NSHTTPURLResponse
                let responseStatusCode = httpResponse.statusCode
                if responseStatusCode == 200
                {
                    serviceCompletionHandler!(receivedData as Data?, error as NSError?)
                }
                else
                {
                    serviceCompletionHandler!((receivedData as Data?) ?? nil, error as NSError?)
                }
            }
        });
        
        dataTask.resume()
        
    }
    class func printWebRequest(request: URLRequest){
        print("Request# \n URL : ",(request.url?.absoluteString as Any),"\n Headers : ",(request.allHTTPHeaderFields?.description as Any),"\n Request Method : ",(request.httpMethod?.description as Any))
        if var jsonBody :Any? = request.httpBody{
            do {
                jsonBody = try JSONSerialization.jsonObject(with: request.httpBody!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Data
            } catch {
                jsonBody = request.httpBody!
            }
            print("\n Body : ",jsonBody as Any)
        }
    }
    class func printResponse(response: Data?){
        if let res = response {
            let resStr = String(data: res, encoding: String.Encoding.utf8)
            print(resStr as Any)
        }
    }
    
    func sendDownloadRequest(_ requestUrl: URL, completionHandler handler: @escaping DownloadHandlerClosureType )
    {
        let documents = UIUtils.documentDirectory() + "/"
        let destinationPath = documents +  requestUrl.lastPathComponent
        let destinationURL = URL(fileURLWithPath: destinationPath)
        if FileManager.default.fileExists(atPath: destinationPath) {
            handler(destinationURL, nil)
            return
        }
        
        if (UIUtils.isConnectedToNetwork() == false)
        {
//            UIUtils.showAlert(withTitle: "Network Error", message: kNetworkErrorMessage, alertType: .info)
            return;
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //        let request = URLRequest(url: requestUrl)
        //        let downloadTask :URLSessionDownloadTask = defaultSession.downloadTask(with: requestUrl, completionHandler: {(locationURL, response, error) in
        
        
        let downloadTask :URLSessionDataTask = defaultSession.dataTask(with: requestUrl, completionHandler: {(data, response, error) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                guard error == nil && data != nil else {
                    print(error ?? "No Error in dowloading task")
                    handler(nil, error as NSError?)
                    return
                }
                
                do {
                    //                    let manager = FileManager.default
                    //                    let documents = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    //                    let destinationURL = documents.appendingPathComponent((response?.suggestedFilename)!)
                    //                    if manager.fileExists(atPath: destinationURL.path) {
                    //                        handler(destinationURL, nil)
                    //                    }
                    
                    try data?.write(to: destinationURL)
                    
                    handler(destinationURL, nil)
                    
                } catch let moveError {
                    print(moveError)
                    handler(nil, moveError as NSError?)
                }
            }
        })
        downloadTask.resume()
    }
    
    class func removeWhitespaceInString(_ string: NSString!) -> NSString
    {
        return string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
    }
}

