//
//  ContactViewController.swift
//  UnitedVision
//
//  Created by Agilink on 08/03/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit
import MessageUI

let kCorpHeadQuarterPhNo = "3372916700"

class ContactViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate
{
    @IBOutlet weak  var tableView: UITableView!
    
    var contactInfoList :[ContactInfo] = []
    
    @IBOutlet var corpHeadQuarterCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleView(withTitle: "CONTACT INFO", Frame: nil)
        
        tableView.estimatedRowHeight = 70
        tableView.contentInset = .zero
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = 0
        
        navigationItem.hidesBackButton = true

        fetchContactList()
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
                self.tableView.dataSource = self
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
        return mailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func corpHeadQuarterCallBtnTapped(_ sender: Any) {
        UIUtils.callPhoneNumber(kCorpHeadQuarterPhNo)
    }
}

extension ContactViewController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactInfoList.count + 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            return corpHeadQuarterCell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableCell", for: indexPath) as! ContactTableCell
            let info = contactInfoList[indexPath.row - 1]
            cell.setCellData(contactInfo: info, indexPath: indexPath)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
