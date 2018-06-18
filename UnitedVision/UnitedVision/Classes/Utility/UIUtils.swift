//  UIUtils.swift
//  ProjectUtility
//


import UIKit
import AudioToolbox
import SystemConfiguration
import MessageUI

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
    
    class func showAlert (withTitle title: String, message msg: String, inContainer container: UIViewController, completionCallbackHandler handler: (() -> Void)? = nil)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { (action: UIAlertAction) -> (Void)
            in
            handler? ()
        })
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
    
//    class func checkPlatformIsSimulator() -> Bool{
//        var isSimulator = false
//        #if targetEnvironment(simulator)
//            isSimulator = true
//        #endif
//        return isSimulator
//    }
    
    class func transparentSearchBarBackgrund(_ searchBar: UISearchBar)
    {
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
    
    class func callPhoneNumber(_ number : String)
    {
        if let url = URL(string: "telprompt://\(number)"), UIApplication.shared.canOpenURL(url) {
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
    
    class func parsePlist(ofName name: String) -> Any? {
        
        // check if plist data available
        guard let plistURL = Bundle.main.url(forResource: name, withExtension: "plist"),
            let data = try? Data(contentsOf: plistURL)
            else {
                return nil
        }
        
        // parse plist into [String: Anyobject]
        guard let plistDictionary = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) else {
            return nil
        }
        
        return plistDictionary
    }
    class func returnCheckOrCrossImage(str : String) -> UIImage! {
        return  str == "Y" ? UIImage(named:"ic_check_circle_green") : UIImage(named:"ic_cancel_circle_red")
    }
    class func returnElement(with tag:Int, from array:[UIView]) -> UIView?{
        for item in array {
            if item.tag == tag{
                return item
            }
        }
        return nil
    }
    class func extractPhNumFromHtml(Html html:String) -> String{
        var phNumber = String()
        if let range = html.range(of: "href='tel:") {
            let hreftag = html[range.upperBound...]
            let remainingString = hreftag
            let splitString = remainingString.split(separator:"'", maxSplits: 1)
            let strings:[String] = splitString.map { String($0) }
            if strings.count > 0{
                phNumber = strings.first!
                print("First Part - ",strings[0])
            }
        }
        else{
            print("not found")
        }

        return phNumber
    }
    
    class func presentMailComposeVC(email: String?, presentingVC: UIViewController){
        let mailComposeViewController = configureMailComposer(email ?? "")
        mailComposeViewController.mailComposeDelegate = presentingVC as? MFMailComposeViewControllerDelegate
        if MFMailComposeViewController.canSendMail(){
            presentingVC.present(mailComposeViewController, animated: true, completion: nil)
        }else{
            print("Can't send email")
        }
    }
    
    class func configureMailComposer(_ receipient :String) -> MFMailComposeViewController{
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.setToRecipients([receipient])
        mailComposeVC.setSubject("United Vision")
        return mailComposeVC
    }
}
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension String{
    func isBlank() -> Bool{
        var isBlank = true
        isBlank = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0
        return isBlank
    }
}

extension Array{
    func elementAt(index: Int) -> Any?{
        if index < 0 || index >= self.count {
            return nil
        }
        else{
            return self[index]
        }
    }
}

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
}
