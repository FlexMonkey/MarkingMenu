//
//  FMMarkingMenuContentViewController.swift
//  
//
//  Created by Simon Gladman on 18/06/2015.
//
//

import UIKit

class FMMarkingMenuContentViewController: UIViewController
{
    let tau = CGFloat(M_PI * 2)
    let pi = CGFloat(M_PI)

    let radius = CGFloat(100)
    let labelRadius = CGFloat(130)
    
    var origin: CGPoint
    
    let markingMenuLayer = CAShapeLayer()
    
    var markingMenuItems: [FMMarkingMenuItem]!
    var markingMenuLayers = [CAShapeLayer]()
    var markingMenuLabels = [UILabel]()
    
    var drawingOffset:CGPoint = CGPointZero
    
    required init(origin: CGPoint)
    {
        self.origin = origin
        
        super.init(nibName: nil, bundle: nil)
        
        view.layer.addSublayer(markingMenuLayer)
        markingMenuLayer.frame = view.bounds
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleMovement(locationInView: CGPoint)
    {
        let drawPath = UIBezierPath(CGPath: markingMenuLayer.path)
        let locationInMarkingMenu = CGPoint(x: locationInView.x + drawingOffset.x, y: locationInView.y + drawingOffset.y)
        
        drawPath.addLineToPoint(locationInMarkingMenu)
        
        markingMenuLayer.path = drawPath.CGPath
        
        let distanceToMenuOrigin = origin.distance(locationInMarkingMenu)
        
        let sectionArc = tau / CGFloat(markingMenuItems.count)
        
        let angle = tau - (((pi * 1.5) + atan2(locationInMarkingMenu.x - origin.x, locationInMarkingMenu.y - origin.y)) )
        
        let segmentIndex = Int((angle < 0 ? tau + angle : angle) / sectionArc )
        
        if CGFloat(distanceToMenuOrigin) > radius
        {
            println("inx =  \(segmentIndex)  \(markingMenuItems[segmentIndex].label)")
            
            if let subItems = markingMenuItems[segmentIndex].subItems where subItems.count > 0
            {
                markingMenuLayers.map({ $0.opacity = $0.opacity * 0.15 })
                markingMenuLabels.map(){ $0.alpha = $0.alpha * 0.15 }
                
                origin = locationInMarkingMenu
                openMarkingMenu(locationInView, markingMenuItems: subItems, clearPath: false)
            }
            else
            {
                // execute....
            }
        }
        
    }
    
    func openMarkingMenu(locationInView: CGPoint, markingMenuItems: [FMMarkingMenuItem], clearPath: Bool = true)
    {
        self.markingMenuItems = markingMenuItems
        
        drawingOffset = CGPoint(x: origin.x - locationInView.x, y: origin.y - locationInView.y)
        
        let segments = CGFloat(markingMenuItems.count)
        let sectionArc = (tau / segments)
        let paddingAngle = tau * 0.02
        
        markingMenuLayer.strokeColor = UIColor.darkGrayColor().CGColor
        markingMenuLayer.fillColor = nil
        markingMenuLayer.lineWidth = 5
        markingMenuLayer.lineJoin = kCALineJoinRound
        markingMenuLayer.lineCap = kCALineCapRound
        
        if clearPath
        {
            let originCircle = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: origin.x - 4, y: origin.y - 4), size: CGSize(width: 8, height: 8)))
            markingMenuLayer.path = originCircle.CGPath
        }
        
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
            
            if (markingMenuItems[i].subItems ?? []).count != 0
            {
                subLayer.lineDashPattern = [10, 10]
            }
            
            markingMenuLayer.addSublayer(subLayer)
            
            let midAngle = (startAngle + endAngle) / 2
            
            let label = UILabel()
            label.text =  " " + markingMenuItems[i].label + " "
            
            markingMenuLabels.append(label)
            
            let labelWidth = label.intrinsicContentSize().width
            let labelHeight = label.intrinsicContentSize().height
            
            let labelXOffset = (midAngle > pi * 0.5 && midAngle < pi * 1.5) ? -labelWidth + 15 : -15
            let labelYOffset = (midAngle > pi) ? -labelHeight : midAngle == pi ? -labelHeight * 0.5 : 0
            
            label.frame = CGRect(origin: CGPoint(
                x: origin.x + labelXOffset + cos(midAngle) * labelRadius,
                y: origin.y + labelYOffset + sin(midAngle) * labelRadius),
                size: CGSize(width: labelWidth, height: labelHeight))
            
            label.layer.backgroundColor = UIColor.lightGrayColor().CGColor
            label.layer.cornerRadius = 4
            label.layer.masksToBounds = false
            
            subLayerPath.addArcWithCenter(origin, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            // join arc to label
            
            subLayerPath.moveToPoint(CGPoint(
                x: origin.x + cos(midAngle) * radius,
                y: origin.y + sin(midAngle) * radius))
            
            subLayerPath.addLineToPoint(CGPoint(
                x: origin.x + cos(midAngle) * (labelRadius + 10),
                y: origin.y + sin(midAngle) * (labelRadius + 10)))
            
            subLayer.path = subLayerPath.CGPath
            
            markingMenuLayers.append(subLayer)
            view.addSubview(label)
        }
    }
    
    func closeMarkingMenu()
    {
        markingMenuLayers.map({ $0.removeFromSuperlayer() })
        markingMenuLabels.map({ $0.removeFromSuperview() })
        
        markingMenuLayers = [CAShapeLayer]()
        markingMenuLabels = [UILabel]()
        
        markingMenuLayer.path = nil
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
