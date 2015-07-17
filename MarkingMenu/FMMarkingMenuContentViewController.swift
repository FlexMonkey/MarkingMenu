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
    var origin = CGPointZero
    var layoutMode = FMMarkingMenuLayoutMode.Circular
    
    let tau = CGFloat(M_PI * 2)
    let pi = CGFloat(M_PI)
    let radius = CGFloat(100)
    let labelRadius = CGFloat(130)
    
    private var visualiseTouches: Bool
    {
        return markingMenu.visualiseTouches
    }
    
    private var touchVisualiser: CAShapeLayer?
    
    private let markingMenuLayer = CAShapeLayer()
    private var markingMenuItems: [FMMarkingMenuItem]!
    private var markingMenuLayers = [CAShapeLayer]()
    private var markingMenuLabels = [UILabel]()
    
    private var drawingOffset:CGPoint = CGPointZero
    
    private var valueSliderInitialAngle: CGFloat? // if not nil, indicates we're in "value slider mode"
    {
        didSet
        {
            if valueSliderInitialAngle == nil
            {
                valueSliderProgressLayer?.removeFromSuperlayer()
                valueSliderProgressLayer = nil
                valueSliderInitialValue = nil
                previousSliderValue = nil
            }
            else
            {
                valueSliderProgressLayer = CAShapeLayer()
                markingMenuLayer.addSublayer(valueSliderProgressLayer!)
                
                valueSliderProgressLayer?.fillColor = nil
                valueSliderProgressLayer?.lineJoin = kCALineJoinRound
                valueSliderProgressLayer?.lineCap = kCALineCapRound
            }
        }
    }
    private var valueSliderIndex: Int?
    private var valueSliderLabel: UILabel?
    private var valueSliderMarkingMenuLayer: CAShapeLayer?
    private var valueSliderInitialValue: CGFloat?
    private var valueSliderProgressLayer: CAShapeLayer?
    private var previousSliderValue:CGFloat?
    
    weak var markingMenu: FMMarkingMenu!
    weak var markingMenuDelegate: FMMarkingMenuDelegate?
    
    required init()
    {
        super.init(nibName: nil, bundle: nil)
        
        view.layer.addSublayer(markingMenuLayer)
        markingMenuLayer.frame = view.bounds
        
        markingMenuLayer.strokeColor = UIColor.whiteColor().CGColor
        markingMenuLayer.fillColor = nil
        markingMenuLayer.lineWidth = 5
        markingMenuLayer.lineJoin = kCALineJoinRound
        markingMenuLayer.lineCap = kCALineCapRound
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
        
        if let touchVisualiser = touchVisualiser
        {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            touchVisualiser.frame = CGRect(origin: locationInView, size: CGSizeZero)
            CATransaction.commit()
        }
        
        let drawPath = UIBezierPath(CGPath: markingMenuLayer.path!)
        let locationInMarkingMenu = CGPoint(x: locationInView.x + drawingOffset.x, y: locationInView.y + drawingOffset.y)
        
        drawPath.addLineToPoint(locationInMarkingMenu)
        
        markingMenuLayer.path = drawPath.CGPath
        
        let distanceToMenuOrigin = origin.distance(locationInMarkingMenu)
       
        let sectionArc = getSectionArc()
        
        let angle: CGFloat
        
        let segmentIndex: Int
        
        if layoutMode == FMMarkingMenuLayoutMode.Circular
        {
            angle = tau - (((pi * 1.5) + atan2(locationInMarkingMenu.x - origin.x, locationInMarkingMenu.y - origin.y)) )
            segmentIndex = Int((angle < 0 ? tau + angle : angle) / sectionArc )
        }
        else
        {
            angle = 0 - (((pi * 0.5) + atan2(locationInMarkingMenu.x - origin.x, locationInMarkingMenu.y - origin.y)) )
            segmentIndex = Int((angle < 0 ? tau + angle : angle) / sectionArc )
        }
        
        if let valueSliderInitialAngle = valueSliderInitialAngle // value slider open....
        {
            let diff: CGFloat
            
            if layoutMode == FMMarkingMenuLayoutMode.Circular
            {
                diff = (angle - valueSliderInitialAngle) < pi ? (angle - valueSliderInitialAngle) : (angle - valueSliderInitialAngle - tau)
            }
            else
            {
                diff = (angle - valueSliderInitialAngle) < -pi
                    ? (angle - valueSliderInitialAngle) + tau
                    : (angle - valueSliderInitialAngle) < pi ? (angle - valueSliderInitialAngle) : (angle - valueSliderInitialAngle - tau)
            }
            
            var normalisedValue = min(max(0, valueSliderInitialValue! + (diff / pi)), 1)
            if previousSliderValue < 0.1 && normalisedValue == 1
            {
                normalisedValue = 0
            }
            else if previousSliderValue > 0.9 && normalisedValue == 0
            {
                normalisedValue = 1
            }
            
            updateSliderProgressLayer(normalisedValue, distanceToMenuOrigin: CGFloat(distanceToMenuOrigin), touchLocation: locationInView)
            
            previousSliderValue = normalisedValue
           
            markingMenuDelegate?.FMMarkingMenuValueSliderChange(markingMenu!, markingMenuItem: markingMenuItems[valueSliderIndex!], newValue: normalisedValue)
        }
        else if CGFloat(distanceToMenuOrigin) > radius && segmentIndex < markingMenuItems.count
        {
            if let subItems = markingMenuItems[segmentIndex].subItems where subItems.count > 0 && valueSliderInitialAngle == nil
            {
                // open sub menu...
                
                markingMenuLayers.map({ $0.opacity = $0.opacity * 0.15 })
                markingMenuLabels.map(){ $0.alpha = $0.alpha * 0.15 }
                
                origin = locationInMarkingMenu
                openMarkingMenu(locationInView, markingMenuItems: subItems, clearPath: false)
            }
            else if markingMenuItems[segmentIndex].isValueSlider
            {
                // enter slider mode...
                
                removeSubComponents(indexToKeep: segmentIndex)
                
                view.layer.shadowColor = nil
                view.layer.shadowOpacity = 0
                
                valueSliderLabel = markingMenuLabels[segmentIndex]
                valueSliderMarkingMenuLayer = markingMenuLayers[segmentIndex]
                valueSliderInitialValue = markingMenuItems[segmentIndex].valueSliderValue
                previousSliderValue = valueSliderInitialValue
                valueSliderInitialAngle = angle
                
                applyDefaultMarkingMenuShadowToLayer(valueSliderLabel!.layer)
                applyDefaultMarkingMenuShadowToLayer(valueSliderMarkingMenuLayer!)
                
                displaySlider(segmentIndex)
                
                updateSliderProgressLayer(valueSliderInitialValue!, distanceToMenuOrigin: CGFloat(distanceToMenuOrigin), touchLocation: locationInView)
            }
            else
            {
                // execute sub menu item...
                
                markingMenuDelegate?.FMMarkingMenuItemSelected(markingMenu!, markingMenuItem: markingMenuItems[segmentIndex])
                
                markingMenu.close()
            }
        }
    }
    
    private func updateSliderProgressLayer(normalisedValue: CGFloat, distanceToMenuOrigin: CGFloat, touchLocation: CGPoint)
    {
        guard let valueSliderProgressLayer = valueSliderProgressLayer,
            valueSliderInitialAngle = valueSliderInitialAngle,
            valueSliderMarkingMenuLayer = valueSliderMarkingMenuLayer,
            valueSliderIndex = valueSliderIndex,
            valueSliderLabel = valueSliderLabel else
        {
            return
        }

        // position label above touch location
        
        markingMenuItems[valueSliderIndex].valueSliderValue = normalisedValue
        valueSliderLabel.text = labelTextForMarkingMenuItem(markingMenuItemIndex: valueSliderIndex)
        
        let labelWidth = valueSliderLabel.intrinsicContentSize().width
        let labelHeight = valueSliderLabel.intrinsicContentSize().height
        
        valueSliderLabel.frame = CGRect(x: touchLocation.x - labelWidth / 2,
            y: touchLocation.y - labelHeight - 40,
            width: labelWidth,
            height: labelHeight)
        valueSliderLabel.alpha = 1
        
        let tweakedValueSliderInitialAngle = valueSliderInitialAngle + (0.5 - valueSliderInitialValue!) * pi
        let startAngle = tweakedValueSliderInitialAngle - (pi / 2)  + (layoutMode == FMMarkingMenuLayoutMode.Circular ? 0 : pi)
        
        // redraw valueSliderMarkingMenuLayer...
        let endAngle = tweakedValueSliderInitialAngle + (pi / 2) + (layoutMode == FMMarkingMenuLayoutMode.Circular ? 0 : pi)
        
        let subLayerPath = UIBezierPath()
        
        subLayerPath.addArcWithCenter(origin, radius: distanceToMenuOrigin, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        valueSliderMarkingMenuLayer.lineDashPattern = nil
        valueSliderMarkingMenuLayer.path = subLayerPath.CGPath
        valueSliderMarkingMenuLayer.opacity = 1
        
        // draw progress bar...
        let progressEndAngle = startAngle + (pi * normalisedValue)
        
        valueSliderProgressLayer.lineWidth = 6
        valueSliderProgressLayer.lineDashPattern = [4, 8]
        valueSliderProgressLayer.strokeColor = UIColor.blueColor().CGColor
        
        let progressSubLayerPath = UIBezierPath()
        
        progressSubLayerPath.addArcWithCenter(origin, radius: distanceToMenuOrigin, startAngle: startAngle, endAngle: progressEndAngle, clockwise: true)
        
        valueSliderProgressLayer.path = progressSubLayerPath.CGPath
    }
    
    private func displaySlider(segmentIndex: Int)
    {
        guard let valueSliderInitialAngle = valueSliderInitialAngle else
        {
            return
        }

        valueSliderIndex = segmentIndex
        
        let subLayer = markingMenuLayers[segmentIndex]
        
        let tweakedValueSliderInitialAngle = valueSliderInitialAngle + (0.5 - valueSliderInitialValue!) * pi
        let startAngle = tweakedValueSliderInitialAngle - (pi / 2) + (layoutMode == FMMarkingMenuLayoutMode.Circular ? 0 : pi)
        let endAngle = tweakedValueSliderInitialAngle + (pi / 2) + (layoutMode == FMMarkingMenuLayoutMode.Circular ? 0 : pi)
        
        subLayer.lineWidth = 8
        subLayer.lineDashPattern = [4, 8]
        
        let subLayerPath = UIBezierPath()
        
        subLayerPath.addArcWithCenter(origin, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // draw connecting line to label. To do: move to common code....

        let sectionArc = getSectionArc()
        let labelLineAngle = (sectionArc * (CGFloat(segmentIndex) + 0.5)) + (layoutMode == FMMarkingMenuLayoutMode.Circular ? 0 : pi)
        
        subLayerPath.moveToPoint(CGPoint(
            x: origin.x + cos(labelLineAngle) * radius,
            y: origin.y + sin(labelLineAngle) * radius))
        
        subLayerPath.addLineToPoint(CGPoint(
            x: origin.x + cos(labelLineAngle) * (labelRadius + 12),
            y: origin.y + sin(labelLineAngle) * (labelRadius + 12)))
        
        subLayer.path = subLayerPath.CGPath
    }
    
    func openMarkingMenu(locationInView: CGPoint, markingMenuItems: [FMMarkingMenuItem], clearPath: Bool = true)
    {
        self.markingMenuItems = markingMenuItems
        
        applyDefaultMarkingMenuShadowToLayer(view.layer)
        
        drawingOffset = CGPoint(x: origin.x - locationInView.x, y: origin.y - locationInView.y)
        
        let sectionArc = getSectionArc()
        let paddingAngle = tau * 0.01
        
        valueSliderInitialAngle = nil
        
        if clearPath
        {
            let originCircle = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: origin.x - 4, y: origin.y - 4), size: CGSize(width: 8, height: 8)))
            markingMenuLayer.path = originCircle.CGPath
            
            if visualiseTouches
            {
                touchVisualiser = CAShapeLayer()
            }
            
            if let touchVisualiser = touchVisualiser
            {
                markingMenuLayer.addSublayer(touchVisualiser)
                
                touchVisualiser.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
                touchVisualiser.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5).CGColor
                touchVisualiser.fillColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.25).CGColor
                
                let circle = UIBezierPath()
                circle.addArcWithCenter(CGPoint(x: 0, y: 0), radius: 30, startAngle: 0, endAngle: tau, clockwise: true)
                touchVisualiser.path = circle.CGPath
                
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                touchVisualiser.frame = CGRect(origin: locationInView, size: CGSizeZero)
                CATransaction.commit()
            }
        }
        
        for var i = 0 ; i < markingMenuItems.count ; i++
        {
            let startAngle = (sectionArc * CGFloat(i)) + paddingAngle + (layoutMode == FMMarkingMenuLayoutMode.Circular ? 0 : pi)
            let endAngle = (sectionArc * CGFloat(i + 1)) - paddingAngle + (layoutMode == FMMarkingMenuLayoutMode.Circular ? 0 : pi)
            
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
            else if (markingMenuItems[i].isValueSlider)
            {
                subLayer.lineWidth = 8
                subLayer.lineDashPattern = [4, 8]
            }
            else
            {
                subLayer.lineWidth = 8
            }
            
            markingMenuLayer.addSublayer(subLayer)
            
            let midAngle = (startAngle + endAngle) / 2
            
            let label = UILabel()
            label.text = labelTextForMarkingMenuItem(markingMenuItemIndex: i)
            label.textColor = markingMenuItems[i].isSelected ? UIColor.redColor() : UIColor.blueColor()
            
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
        removeSubComponents()
        
        valueSliderProgressLayer?.path = nil
        valueSliderProgressLayer?.removeFromSuperlayer()
        
        touchVisualiser?.path = nil
        touchVisualiser?.removeFromSuperlayer()
        touchVisualiser = nil
        
        markingMenuLayers = [CAShapeLayer]()
        markingMenuLabels = [UILabel]()
        
        markingMenuLayer.path = nil
        valueSliderMarkingMenuLayer = nil
    }
    
    // MARK: utilities
    
    func getSectionArc() -> CGFloat
    {
        let segments = CGFloat(markingMenuItems.count)
        let sectionArc = (tau / segments) / (layoutMode == FMMarkingMenuLayoutMode.Circular ? 1.0 : 2.0)
        
        return sectionArc
    }
    
    func removeSubComponents(indexToKeep indexToKeep: Int = -1)
    {
        for (idx, layerLabelTuple) in zip(markingMenuLayers, markingMenuLabels).enumerate() where idx != indexToKeep
        {
            layerLabelTuple.0.removeFromSuperlayer()
            layerLabelTuple.1.removeFromSuperview()
        }
    }
    
    func labelTextForMarkingMenuItem(markingMenuItemIndex i: Int) -> String
    {
        return " " + markingMenuItems[i].label + (markingMenuItems[i].isValueSlider ? " \(Int(markingMenuItems[i].valueSliderValue * 100))% " : " ")
    }
    
}


