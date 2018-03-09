//  UIUtils.swift
//  ProjectUtility
//


import UIKit
import AudioToolbox
import SystemConfiguration

class UIUtils: NSObject {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    
    //MARK: - Validation Methods
    
    class func validateEmail(_ testStr:String) -> Bool {

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest : NSPredicate! = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }

    
    class func validatePhoneNr(_ value: String) -> Bool {
        
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: value, options: [], range: NSMakeRange(0, value.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == value.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    class func validatePassword (pass: String) -> Bool
    {
        
        let passRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?~,'<>;:^&])[A-Za-z\\d$@$!%*#?~,<>';:^.&]{6,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passRegex)
        print (passwordTest.evaluate(with: pass))
        return passwordTest.evaluate(with: pass)
    }
  
    class func validateDisplayName(_ testStr:String) -> Bool {
        NSLog("validate name: \(testStr)")
        let nameRegex = "^[a-zA-Z]*$"
        
        let nameTest : NSPredicate! = NSPredicate(format:"SELF MATCHES %@", nameRegex)
        let result = nameTest.evaluate(with: testStr)
        return result
    }
    
    //MARK: - JSON Methods
    
    class func getJSONFromData(_ jsonData : Data!) -> Any?
    {
        var json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: jsonData as Data, options: .allowFragments )
        } catch {
            print(error)
        }
        
        return json
    }
    
    class func getJsonPostString(_ value: AnyObject) -> String {
        
        if JSONSerialization.isValidJSONObject(value)
        {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted)
                if let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return jsonString as String
                }
            } catch {
                print(error)
            }
        }
        return ""
    }
    
    class func showAlert(withTitle title: String, message msg: String, inContainer container:UIViewController)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        container.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - File Handling methods
    
    class func documentDirectoryWithSubpath(subpath: String?) -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        var basePath: String! = (paths.count > 0) ? paths[0] : nil
        if let path = subpath
        {
            basePath = basePath + path
        }
        
        return basePath
    }
    
    class func saveFileWithData(data: NSData, withFilepath filepath: String)
    {
        let fileContent : NSString = NSString(data: data as Data, encoding: String.Encoding.isoLatin1.rawValue)!
        
        let pathArray : [String] = filepath.components(separatedBy: "/")
        let pathArr = NSMutableArray(array: pathArray)
        pathArr.removeLastObject()
        var pathStr = pathArr[0] as! String
        
        for i in 1...pathArr.count
        {
            pathStr = pathStr + (pathArr[i] as! String)
        }
        
        self.createDirectoryAtPath(path: pathStr)
        
        do {
            try fileContent.write(toFile: filepath, atomically: true, encoding: String.Encoding.isoLatin1.rawValue)
        } catch let error as NSError {
            NSLog("Unable to wtrite file \(error.debugDescription)")
        }
    }
    
    class func saveImageWithData(data: NSData, withFilepath filepath: String) -> Bool
    {
        let pathArray : [String] = filepath.components(separatedBy: "/")
        let pathArr = NSMutableArray(array: pathArray)
        pathArr.removeLastObject()
        var pathStr = pathArr[0] as! String
        
        for i in 1...pathArr.count
        {
            pathStr = pathStr + (pathArr[i] as! String)
        }
        
        self.createDirectoryAtPath(path: pathStr)
        
        return data.write(toFile: filepath, atomically: true)
    }
    
    
    class func documentDirectory() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
    
    class func createDirectoryAtPath(path : String)
    {
        let fileManager = FileManager.default
        let fileURL = URL(fileURLWithPath: path)
        do {
            try fileManager.createDirectory(at: fileURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }
    
    class func isFileExistAtPath(path : String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    class func sizeForLocalFilePath(fileURL:URL) -> Float {
        
        // Return File size in MB
        do {
            let filePath = fileURL.path
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSizeNumber = fileAttributes[FileAttributeKey.size] {
                let fileSize =  (fileSizeNumber as! NSNumber).doubleValue
                let sizeMB = Float (fileSize / (1024.0*1024.0))
                print("File Size in MB:\(sizeMB)")
                return sizeMB
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(fileURL) with error: \(error)")
        }
        return 0
    }
    
    class func string(fromDate date:Date, inFormat format:String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
    }
    
    class func checkPlatformIsSimulator() -> Bool{
        var isSimulator = false
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            isSimulator = true
        #endif
        return isSimulator
    }
    
    
    // Return the server urls as per the satging/production state of the appp
    class func getServerURl() -> String?
    {
        if let path = Bundle.main.path(forResource: "Server", ofType: "plist")
        {
            //If your plist contain root as Dictionary
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {

                if (dic["Production"] as! Bool)
                {
                    return kProductionURL
                }
                else
                {
                    return kStagingURL
                }
            }
        }
        return nil
    }
    
    class func transparentSearchBarBackgrund(_ searchBar: UISearchBar)
    {
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
    
    class func callPhoneNumber(_ number : String)
    {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else {
            print("Your device doesn't support this feature.")
        }
    }
    
    class func parsePlist(ofName name: String) -> [Dictionary<String, AnyObject>]? {
        
        // check if plist data available
        guard let plistURL = Bundle.main.url(forResource: name, withExtension: "plist"),
            let data = try? Data(contentsOf: plistURL)
            else {
                return nil
        }
        
        // parse plist into [String: Anyobject]
        guard let plistDictionary = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [Dictionary<String, AnyObject>] else {
            return nil
        }
        
        return plistDictionary
    }
}
