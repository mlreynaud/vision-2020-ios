//
//  LoadingView.swift
//  

import UIKit

class LoadingView: UIView {

    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()

    class var shared: LoadingView {
        struct Static {
            static let instance: LoadingView = LoadingView()
        }
        return Static.instance
    }

//    func showOverlay(view: UIView) {
    
        func showOverlay() {

        let window = UIApplication.shared.keyWindow
            
        overlayView.frame = window!.bounds;
//        overlayView.center = window!.center
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        overlayView.clipsToBounds = true
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)//CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .white
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        
        overlayView.addSubview(activityIndicator)
        window!.addSubview(overlayView)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }

}

