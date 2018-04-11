//
//  BaseViewController.swift
//  UnitedVision
//
//  Created by Agilink on 06/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = []
        self.automaticallyAdjustsScrollViewInsets = false
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
   
}

extension UIViewController{
    func setTitleView(withTitle title: String,Frame frame:CGRect?) {
        let titleView = TitleView.loadViewFromNib()
        titleView.setTitle(Title: title, Frame: frame)
        self.navigationItem.titleView = titleView
    }
}
