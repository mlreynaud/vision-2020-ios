//
//  LoadBoardPopUpVC.swift
//  UnitedVision
//
//  Created by Simrandeep Singh on 13/06/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class LoadBoardPopUpVC: UIViewController {

    @IBOutlet weak var originDescLbl: UILabel!
    @IBOutlet weak var destinationDescLbl : UILabel!
    @IBOutlet weak var pickupDateDescLbl: UILabel!
    @IBOutlet weak var deliveryDateDescLbl : UILabel!
    @IBOutlet weak var distanceDescLbl: UILabel!
    @IBOutlet weak var weightDescLbl: UILabel!
    @IBOutlet weak var tractorTypeDescLbl : UILabel!
    @IBOutlet weak var trailerDescLbl: UILabel!
    @IBOutlet weak var orderDescLbl : UILabel!
    @IBOutlet weak var terminalDescLbl: UILabel!
    @IBOutlet weak var commodityDescLbl : UILabel!
    @IBOutlet weak var estimatedChargeLbl: UILabel!
    
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var hazmatImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var backGreyView: UIView!
    
    var phoneNumStr: String?

    var loadBoardInfo: LoadBoardInfo?
    
    class func initiatePopOverVC() -> LoadBoardPopUpVC{
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return (storyBoard.instantiateViewController(withIdentifier: "LoadBoardPopUpVC") as? LoadBoardPopUpVC)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backGreyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelBtnTapped)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCellData()
    }
    
    func setCellData(){
        originDescLbl.text = loadBoardInfo?.originCityState ?? ""
        destinationDescLbl.text = loadBoardInfo?.destCityState ?? ""
        pickupDateDescLbl.text = loadBoardInfo?.pickupDateStr ?? ""
        deliveryDateDescLbl.text = loadBoardInfo?.deliveryDateStr ?? ""
        distanceDescLbl.text = "\(loadBoardInfo?.distance ?? 0.0)"
        hazmatImageView.image = (loadBoardInfo?.hazmat ?? false) ? UIImage(named:"ic_check_circle_green") : UIImage(named:"ic_cancel_circle_red")
        weightDescLbl.text = "\(loadBoardInfo?.weight ?? 0.0)"
        tractorTypeDescLbl.text = loadBoardInfo?.tractorType ?? ""
        estimatedChargeLbl.text = loadBoardInfo?.estimatedCharge ?? ""
        trailerDescLbl.text = loadBoardInfo?.trailerType ?? ""
        orderDescLbl.text = loadBoardInfo?.orderId ?? ""
        terminalDescLbl.text = loadBoardInfo?.terminalDesc ?? ""
        commodityDescLbl.text = loadBoardInfo?.commodityDesc ?? ""
        phoneNumStr = loadBoardInfo?.terminalPhone ?? ""
        containerView.sizeToFit()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let dispatchTime = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline:dispatchTime) {
            self.containerView.sizeToFit()
        }
    }
    
    @IBAction func cancelBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callBtnTapped() {
        if let phNumStr = phoneNumStr, !phNumStr.isBlank(){
            UIUtils.callPhoneNumber(phNumStr)
        }
    }

}
