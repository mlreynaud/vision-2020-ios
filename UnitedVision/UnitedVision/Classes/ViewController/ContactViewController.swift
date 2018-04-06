//
//  ContactViewController.swift
//  UnitedVision
//
//  Created by Agilink on 08/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit
import MessageUI


class ContactViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate
{
    @IBOutlet weak  var tableView: UITableView!
    
    var contactInfoList :[ContactInfo] = []
    
//    let departmentList = ["Corporate Headquarters", "Sales", "Driver opprtunities", "Corporate Communications", "Operations", "Brokerage", "Driver Verifications", "Website Support", "Logistics", "Safety", "Driver Qualtifications"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = "Contact Info"
        setTitleView(withTitle: "Contact Info", Frame: nil)
        tableView.estimatedRowHeight = 70
        tableView.contentInset = .zero
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedSectionHeaderHeight = 0
        tableView.sectionHeaderHeight = 0
        
        navigationItem.hidesBackButton = true

        fetchContactList()
//        self.readPropertyList();
    }
    func fetchContactList() {
        LoadingView.shared.showOverlay()

        DataManager.sharedInstance.fetchContactList { (status, contactList, error) in
            LoadingView.shared.hideOverlayView()

            if status{
                for contactDict in contactList!{
                    let contactInfo = ContactInfo(info: contactDict)
                    self.contactInfoList.append(contactInfo)
                }
                self.tableView.reloadData()
            }
            else{
                UIUtils.showAlert(withTitle: kAppTitle, message: error?.localizedDescription ?? "Something went wrong,Please try again later", inContainer: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.navigationController?.topViewController?.isKind(of: ContactViewController.self))!
        {
            self.setNavigationBarItem()
        }
        
    }

//    func readPropertyList()
//    {
//        if let list = UIUtils.parsePlist(ofName: "ContactInfo") as? Array<Any>
//        {
//            for dict in list
//            {
//                let info = ContactInfo(info: dict as! Dictionary<String, Any>)
//                contactList.append(info)
//            }
//        }
//    }
    
    @IBAction func callButtonAction(_ sender: UIButton)
    {
        let info = contactInfoList[sender.tag]
        UIUtils.callPhoneNumber(info.phone!)
    }
    
    @IBAction func mailButtonAction(_ sender: UIButton)
    {
        let info = contactInfoList[sender.tag]
        let mailComposeViewController = configureMailComposer(info.email!)
        if MFMailComposeViewController.canSendMail(){
            self.present(mailComposeViewController, animated: true, completion: nil)
        }else{
            print("Can't send email")
        }
    }
    
    func configureMailComposer(_ receipient :String) -> MFMailComposeViewController
    {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([receipient])
        mailComposeVC.setSubject("United Vision")
//        mailComposeVC.setMessageBody(self.textViewBody.text!, isHTML: false)
        return mailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension ContactViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactInfoList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableCell", for: indexPath) as! ContactTableCell
        let info = contactInfoList[indexPath.row]
        cell.setCellData(contactInfo: info, indexPath: indexPath)
        return cell;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
