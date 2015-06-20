//
//  FMMarkingMenuContentViewController.swift
//  
//
//  Created by Simon Gladman on 18/06/2015.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>

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
    
    let selectionLabel = UILabel()
    
    weak var markingMenu: FMMarkingMenu!
    weak var markingMenuDelegate: FMMarkingMenuDelegate?
    
    required init(origin: CGPoint)
    {
        self.origin = origin
        
        super.init(nibName: nil, bundle: nil)
        
        view.layer.addSublayer(markingMenuLayer)
        markingMenuLayer.frame = view.bounds
        
        selectionLabel.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        selectionLabel.layer.cornerRadius = 4
        view.addSubview(selectionLabel)
        
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 2
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleMovement(locationInView: CGPoint)
    {
        if markingMenuLayer.path == nil
        {
            return
        }
        
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
            selectionLabel.text = selectionLabel.text! + (selectionLabel.text!.isEmpty ? " " : " → ") + markingMenuItems[segmentIndex].label + " "
            selectionLabel.frame = CGRect(x: view.frame.width / 2 - selectionLabel.intrinsicContentSize().width / 2, y: 40, width: selectionLabel.intrinsicContentSize().width, height: selectionLabel.intrinsicContentSize().height)
            
            if let subItems = markingMenuItems[segmentIndex].subItems where subItems.count > 0
            {
                markingMenuLayers.map({ $0.opacity = $0.opacity * 0.15 })
                markingMenuLabels.map(){ $0.alpha = $0.alpha * 0.15 }
                
                origin = locationInMarkingMenu
                openMarkingMenu(locationInView, markingMenuItems: subItems, clearPath: false)
            }
            else
            {
                markingMenuDelegate?.FMMarkingMenuItemSelected(markingMenu!, markingMenuItem: markingMenuItems[segmentIndex])
                
                closeMarkingMenu()
                
                UIView.animateWithDuration(0.75, animations: {self.selectionLabel.alpha = 0}, completion: {_ in self.markingMenu.close()})
            }
        }
    }
    
    func openMarkingMenu(locationInView: CGPoint, markingMenuItems: [FMMarkingMenuItem], clearPath: Bool = true)
    {
        self.markingMenuItems = markingMenuItems
        
        drawingOffset = CGPoint(x: origin.x - locationInView.x, y: origin.y - locationInView.y)
        
        let segments = CGFloat(markingMenuItems.count)
        let sectionArc = (tau / segments)
        let paddingAngle = tau * 0.01
        
        markingMenuLayer.strokeColor = UIColor.whiteColor().CGColor
        markingMenuLayer.fillColor = nil
        markingMenuLayer.lineWidth = 5
        markingMenuLayer.lineJoin = kCALineJoinRound
        markingMenuLayer.lineCap = kCALineCapRound
        
        if clearPath
        {
            selectionLabel.text = ""
            selectionLabel.frame = CGRectZero
            selectionLabel.alpha = 1
            
            let originCircle = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: origin.x - 4, y: origin.y - 4), size: CGSize(width: 8, height: 8)))
            markingMenuLayer.path = originCircle.CGPath
        }
        
        for var i = 0 ; i < markingMenuItems.count ; i++
        {
            let startAngle = (sectionArc * CGFloat(i)) + paddingAngle
            let endAngle = (sectionArc * CGFloat(i + 1)) - paddingAngle
            
            let subLayer = CAShapeLayer()
            let subLayerPath = UIBezierPath()
            
            subLayer.strokeColor = UIColor.lightGrayColor().CGColor
            subLayer.fillColor = nil
            subLayer.lineCap = kCALineCapRound
            
            if (markingMenuItems[i].subItems ?? []).count != 0
            {
                subLayer.lineWidth = 4
                subLayer.lineDashPattern = [1, 4]
            }
            else
            {
                subLayer.lineWidth = 8
            }
            
            markingMenuLayer.addSublayer(subLayer)
            
            let midAngle = (startAngle + endAngle) / 2
            
            let label = UILabel()
            label.text = " " + markingMenuItems[i].label + " "
            
            markingMenuLabels.append(label)
            
            let labelWidth = label.intrinsicContentSize().width
            let labelHeight = label.intrinsicContentSize().height
            
            let labelXOffsetTweak = (midAngle > pi * 0.45 && midAngle < pi * 0.55) || (midAngle > pi * 1.45 && midAngle < pi * 1.55) ? label.intrinsicContentSize().width / 2 : 15
            
            let labelXOffset = (midAngle > pi * 0.5 && midAngle < pi * 1.5) ? -labelWidth + labelXOffsetTweak : -labelXOffsetTweak
            let labelYOffset = (midAngle > pi) ? -labelHeight : midAngle == pi ? -labelHeight * 0.5 : 0
            
            label.frame = CGRect(origin: CGPoint(
                x: origin.x + labelXOffset + cos(midAngle) * labelRadius,
                y: origin.y + labelYOffset + sin(midAngle) * labelRadius),
                size: CGSize(width: labelWidth, height: labelHeight))
            
            label.layer.backgroundColor = UIColor.lightGrayColor().CGColor
            label.layer.cornerRadius = 4
            label.layer.masksToBounds = false
            label.alpha = 0
            
            subLayerPath.addArcWithCenter(origin, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            // join arc to label
            
            subLayerPath.moveToPoint(CGPoint(
                x: origin.x + cos(midAngle) * radius,
                y: origin.y + sin(midAngle) * radius))
            
            subLayerPath.addLineToPoint(CGPoint(
                x: origin.x + cos(midAngle) * (labelRadius + 12),
                y: origin.y + sin(midAngle) * (labelRadius + 12)))
            
            subLayer.path = subLayerPath.CGPath
    
            markingMenuLayers.append(subLayer)
            view.addSubview(label)
            
            UIView.animateWithDuration(0.1, animations: {label.alpha = 1})
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


