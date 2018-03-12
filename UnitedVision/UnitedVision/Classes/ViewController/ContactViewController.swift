//
//  ContactViewController.swift
//  UnitedVision
//
//  Created by Meenakshi Pathani on 08/03/18.
//  Copyright © 2018 Meenakshi Pathani. All rights reserved.
//

import UIKit
import MessageUI


class ContactViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate
{
    @IBOutlet weak  var tableView: UITableView!
    
    var contactList :[ContactInfo] = []
    
    let departmentList = ["Corporate Headquarters", "Sales", "Driver opprtunities", "Corporate Communications", "Operations", "Brokerage", "Driver Verifications", "Website Support", "Logistics", "Safety", "Driver Qualtifications"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Contact Info"
        
        self.readPropertyList();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.navigationController?.viewControllers[0].isKind(of: ContactViewController.self))!
        {
            self.setNavigationBarItem()
        }
        
    }

    func readPropertyList()
    {
        if let list = UIUtils.parsePlist(ofName: "ContactInfo") as? NSArray
        {
            for dict in list
            {
                let info = ContactInfo(info: dict as! NSDictionary)
                contactList.append(info)
            }
        }
    }
    
    @IBAction func callButtonAction(_ sender: UIButton)
    {
        let info = contactList[sender.tag]
        UIUtils.callPhoneNumber(info.mobile!)
    }
    
    @IBAction func mailButtonAction(_ sender: UIButton)
    {
        let info = contactList[sender.tag]
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
        return contactList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableCell", for: indexPath) as! ContactTableCell
        
        let info = contactList[indexPath.row]
        
        cell.titleLabel.text = info.title!
        cell.detailLabel.text = info.detail!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        cell.emailButton.isHidden = (info.email!.count > 0) ? false : true
        cell.callButton.isHidden = (info.mobile!.count > 0) ? false : true
        
        cell.emailButton.tag = indexPath.row
        cell.callButton.tag = indexPath.row

        return cell;
    }

}
