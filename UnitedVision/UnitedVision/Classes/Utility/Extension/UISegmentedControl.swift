//
//  UISegmentedControl.swift
//  UnitedVision
//
//  Created by Agilink on 28/02/18.
//  Copyright © 2018 Agilink. All rights reserved.
//

import Foundation

extension UISegmentedControl{
    
    func removeBorder(){
        let backgroundImage = UIImage.getColoredRectImageWith(color: UIColor.clear.cgColor, andSize: self.bounds.size)
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)
        
        let deviderImage = UIImage.getColoredRectImageWith(color: UIColor.clear.cgColor, andSize: CGSize(width: 1.0, height: self.bounds.size.height))
        self.setDividerImage(deviderImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray], for: .normal)
        self.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(red: 67/255, green: 129/255, blue: 244/255, alpha: 1.0)], for: .selected)
    }
    
    func addUnderlineForSelectedSegment(){
        let underlineWidth: CGFloat = self.frame.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = 2.0
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = self.bounds.size.height - 1.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.backgroundColor = UIColor(red: 67/255, green: 129/255, blue: 244/255, alpha: 1.0)
        underline.tag = 1
        self.addSubview(underline)
    }
    
    func changeUnderlinePosition(){
        guard let underline = self.viewWithTag(1) else {return}
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)
        UIView.animate(withDuration: 0.1, animations: {
            underline.frame.origin.x = underlineFinalXPosition
        })
    }
    
    func updateUnderLineWidth(){
        guard let underline = self.viewWithTag(1) else {return}
        let newWidth = self.frame.size.width
        let newUnderlineWidth = newWidth/CGFloat(numberOfSegments)
        UIView.animate(withDuration: 0.1, animations: {
            underline.frame = CGRect(x: underline.frame.origin.x, y: underline.frame.origin.y, width: newUnderlineWidth, height: underline.frame.size.height)
            let underlineFinalXPosition = (newWidth / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
            underline.frame.origin.x = underlineFinalXPosition
        })
    }
}

extension UIImage{
    
    class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
}
