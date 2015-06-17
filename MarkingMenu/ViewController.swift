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
    
    let markingMenuItems = [" Blur ", " Sharpen " , " Stylize ", " Color Effect ", " Color Adjustment "  , " Halftone Effect " , " Distortion Effect "]
    let radius = CGFloat(100)
    let labelRadius = CGFloat(130)
    let tau = CGFloat(M_PI * 2)
    let pi = CGFloat(M_PI)
    
    var drawingOffset:CGPoint = CGPointZero
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesBegan(touches, withEvent: event)
        
        let locationInView = (touches.first as! UITouch).locationInView(self.view)
        let centre = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        
        drawingOffset = CGPoint(x: centre.x - locationInView.x, y: centre.y - locationInView.y)
        
        openMarkingMenu()
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesEnded(touches, withEvent: event)
        
        closeMarkingMenu()
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesMoved(touches, withEvent: event)
        
        let centre = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        let drawPath = UIBezierPath(CGPath: markingMenuLayer.path)
        let locationInView = (touches.first as! UITouch).locationInView(self.view)
        let locationInMarkingMenu = CGPoint(x: locationInView.x + drawingOffset.x, y: locationInView.y + drawingOffset.y)
        
        drawPath.addLineToPoint(locationInMarkingMenu)
        
        markingMenuLayer.path = drawPath.CGPath
        
        let distanceToMenuOrigin = centre.distance(locationInMarkingMenu)
        
        let sectionArc = tau / CGFloat(markingMenuItems.count)
        
        let angle = tau - (((pi * 1.5) + atan2(locationInMarkingMenu.x - centre.x, locationInMarkingMenu.y - centre.y)) )
        
        let segmentIndex = Int((angle < 0 ? tau + angle : angle) / sectionArc )// % markingMenuItems.count
        
        println("inx =  \(segmentIndex)  \(markingMenuItems[segmentIndex]) angle = \(angle.radiansToDegrees())")
    }
    
    
    func openMarkingMenu()
    {
        view.layer.addSublayer(markingMenuLayer)
        
        markingMenuLayer.frame = view.bounds
        
        let segments = CGFloat(markingMenuItems.count)
        
        let centre = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)

        let sectionArc = (tau / segments)
        let paddingAngle = tau * 0.01
    
        markingMenuLayer.strokeColor = UIColor.darkGrayColor().CGColor
        markingMenuLayer.fillColor = nil
        markingMenuLayer.lineWidth = 5
        markingMenuLayer.lineJoin = kCALineJoinRound
        markingMenuLayer.lineCap = kCALineCapRound
        
        let originCircle = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: centre.x - 4, y: centre.y - 4), size: CGSize(width: 8, height: 8)))
        markingMenuLayer.path = originCircle.CGPath
        
        for var i = 0 ; i < Int(segments) ; i++
        {
            let startAngle = (sectionArc * CGFloat(i)) + paddingAngle
            let endAngle = (sectionArc * CGFloat(i + 1)) - paddingAngle
            
            let subLayer = CAShapeLayer()
            let subLayerPath = UIBezierPath()
            
            subLayer.strokeColor = UIColor.lightGrayColor().CGColor
            subLayer.fillColor = nil
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
    
    func closeMarkingMenu()
    {
        markingMenuLayer.removeFromSuperlayer()
    }
    
}

extension CGPoint
{
    func distance(otherPoint: CGPoint) -> Float
    {
        let xSquare = Float((self.x - otherPoint.x) * (self.x - otherPoint.x))
        let ySquare = Float((self.y - otherPoint.y) * (self.y - otherPoint.y))
        
        return sqrt(xSquare + ySquare)
    }
}

let π = CGFloat(M_PI)

public extension CGFloat
{
    public func degreesToRadians() -> CGFloat
    {
        return π * self / 180.0
    }
    
    public func radiansToDegrees() -> CGFloat
    {
        return self * 180.0 / π
}
}


