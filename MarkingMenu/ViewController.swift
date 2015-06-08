//
//  ViewController.swift
//  MarkingMenu
//
//  Created by Simon Gladman on 07/06/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let markingMenuLayer = CAShapeLayer()
    
    let markingMenuItems = [" Blur ", " Sharpen " , " Stylize ", " Color Effect " , " Color Adjustment "  , " Halftone Effect " , " Distortion Effect "]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.layer.addSublayer(markingMenuLayer)
        
        markingMenuLayer.frame = view.bounds
        
        let segments = CGFloat(markingMenuItems.count)
        
        let centre = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        let radius = CGFloat(100)
        let labelRadius = CGFloat(130)
        let tau = CGFloat(M_PI * 2)
        let pi = CGFloat(M_PI)
        let sectionArc = (tau / segments)
        let paddingAngle = tau * 0.02
        
        for var i = 0 ; i < Int(segments) ; i++
        {
            let startAngle = (sectionArc * CGFloat(i)) + paddingAngle
            let endAngle = (sectionArc * CGFloat(i + 1)) - paddingAngle
            
            let subLayer = CAShapeLayer()
            let subLayerPath = UIBezierPath()
            
            subLayer.strokeColor = UIColor.lightGrayColor().CGColor
            subLayer.fillColor = UIColor.clearColor().CGColor
            subLayer.lineWidth = 8
            subLayer.lineCap = kCALineCapRound

            markingMenuLayer.addSublayer(subLayer)
            
            let midAngle = (startAngle + endAngle) / 2
            
            let label = UILabel()
            label.text =  markingMenuItems[i] // "\(midAngle)" //
            
            let labelWidth = label.intrinsicContentSize().width
            let labelHeight = label.intrinsicContentSize().height
            
            let labelXOffset = (midAngle > pi * 0.5 && midAngle < pi * 1.5) ? -labelWidth + 15 : -15
            let labelYOffset = (midAngle > pi) ? -labelHeight : midAngle == pi ? -labelHeight * 0.5 : 0
            
            label.frame = CGRect(origin: CGPoint(
                        x: centre.x + labelXOffset + cos(midAngle) * labelRadius,
                        y: centre.y + labelYOffset + sin(midAngle) * labelRadius),
                size: CGSize(width: labelWidth, height: labelHeight))
            
            label.layer.backgroundColor = UIColor.lightGrayColor().CGColor
            label.layer.cornerRadius = 4
            label.layer.masksToBounds = false
            
            subLayerPath.addArcWithCenter(centre, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            subLayerPath.moveToPoint(CGPoint(
                x: centre.x + cos(midAngle) * radius,
                y: centre.y + sin(midAngle) * radius))

            subLayerPath.addLineToPoint(CGPoint(
                x: centre.x + cos(midAngle) * (labelRadius + 10),
                y: centre.y + sin(midAngle) * (labelRadius + 10)))
            
           
            
            subLayer.path = subLayerPath.CGPath
            
            view.addSubview(label)
        }
    
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesBegan(touches, withEvent: event)
    }
    
    
}

