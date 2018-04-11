//
//  LoadingView.swift
//

import UIKit

class LoadingView: UIView {
    
    var overlayView = UIView()
    var rotationIcon = UIImageView()
    var appLogo = UIImageView()
    
    static let shared = LoadingView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        let window = UIApplication.shared.keyWindow
        super.init(frame:(window?.frame)!)

        overlayView.frame = window!.bounds;
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        overlayView.clipsToBounds = true

        rotationIcon.image = UIImage(named: "ic_reset_white")
        rotationIcon.contentMode = .scaleAspectFill
        rotationIcon.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        rotationIcon.center = overlayView.center

        appLogo.image = UIImage(named: "uv_shield_50")
        appLogo.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        appLogo.center = overlayView.center
        
        overlayView.addSubview(rotationIcon)
        overlayView.addSubview(appLogo)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc func rotated() {
        let window = UIApplication.shared.keyWindow
        overlayView.frame = window!.bounds;
        appLogo.center = overlayView.center
        rotationIcon.center = overlayView.center
    }
    
    func showOverlay() {
        rotated()
        animateLoader()
        let window = UIApplication.shared.keyWindow
        window!.addSubview(overlayView)
    }
    
    func hideOverlayView() {
        stopAnimateLoader()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        overlayView.removeFromSuperview()
    }

    let kRotationAnimationKey = "rotationanimationkey"
    
    func animateLoader() {
        if rotationIcon.layer.animation(forKey: kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")

            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = 1
            rotationAnimation.repeatCount = Float.infinity

            rotationIcon.layer.add(rotationAnimation, forKey: kRotationAnimationKey)
        }
    }

    func stopAnimateLoader() {
        if rotationIcon.layer.animation(forKey: kRotationAnimationKey) != nil {
            rotationIcon.layer.removeAnimation(forKey: kRotationAnimationKey)
        }
    }
    
}

