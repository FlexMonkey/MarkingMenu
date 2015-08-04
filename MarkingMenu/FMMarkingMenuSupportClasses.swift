//
//  FMMarkingMenuSupportClasses.swift
//  MarkingMenu
//
//  Created by Simon Gladman on 18/06/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
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

class FMMarkingMenuItem
{
    let label: String
    let subItems: [FMMarkingMenuItem]?  // subItems trump isValueSlider
    let isValueSlider:Bool
    
    var valueSliderValue: CGFloat = 0.0
    
    // Colors the menu item to indicate selection. Selection logic needs to be implemented in host application
    var isSelected: Bool = false
    
    // Optional category for use in host application
    var category: String?
    
    required init(label: String, subItems: [FMMarkingMenuItem]? = nil, isValueSlider: Bool = false)
    {
        self.label = label
        self.subItems = subItems
        self.isValueSlider = isValueSlider
    }
    
    convenience init(label: String, valueSliderValue: CGFloat)
    {
        self.init(label: label, subItems: [], isValueSlider: true)
        
        self.valueSliderValue = valueSliderValue
    }
    
    convenience init(label: String, category: String, isSelected: Bool = false)
    {
        self.init(label: label, subItems: [], isValueSlider: false)
        
        self.category = category
        self.isSelected = isSelected
    }
}

enum FMMarkingMenuLayoutMode
{
    case Circular       // displays menu items over the full circumference of a circle
    case SemiCircular   // displays menu items over half the circumference of a circle from 9 o'clock through 3 o'clock (clockwise)
}

enum FMMarkingMenuLaunchMode
{
    case OpenAtScreenCentre
    case OpenAtTouchLocation
}

protocol FMMarkingMenuDelegate: NSObjectProtocol
{
    func FMMarkingMenuItemSelected(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem)
    
    func FMMarkingMenuValueSliderChange(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem, newValue: CGFloat)
}

// A button like object that opens a marking menu
class FMMarkingMenuWidget: UIView
{
    private let labelControl = UILabel()
    private let touchView = UIView()
    private let markingMenu: FMMarkingMenu
    
    required init(label: String, viewController: UIViewController, markingMenuItems: [FMMarkingMenuItem])
    {
        labelControl.text = label
        labelControl.textAlignment = NSTextAlignment.Center
        labelControl.textColor = UIColor.blueColor()
        
        touchView.layer.cornerRadius = 5
        touchView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        
        applyDefaultMarkingMenuShadowToLayer(touchView.layer)
        
        markingMenu = FMMarkingMenu(viewController: viewController,
            view: touchView,
            markingMenuItems: markingMenuItems)
        
        super.init(frame: CGRectZero)
        
        addSubview(touchView)
        addSubview(labelControl)
        
        backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.75)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var markingMenuDelegate: FMMarkingMenuDelegate?
    {
        set
        {
            markingMenu.markingMenuDelegate = newValue
        }
        get
        {
            return markingMenu.markingMenuDelegate
        }
    }
    
    override func layoutSubviews()
    {
        touchView.frame = bounds.rectByInsetting(dx: 20, dy: 20)
        labelControl.frame = bounds
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: 100, height: 75)
    }
}

// An extended UIPanGestureRecognizer that fires UIGestureRecognizerState.Began
// with the first touch down, i.e. without requiring any movement.
class FMMarkingMenuPanGestureRecognizer: UIPanGestureRecognizer
{
    required init(target: AnyObject?, action: Selector, markingMenu: FMMarkingMenu)
    {
        self.markingMenu = markingMenu
        
        super.init(target: target, action: action)
    }
    
    let markingMenu: FMMarkingMenu
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        let locationInView = touches.first!.locationInView(markingMenu.view)
        
        // invoking open on the marking menu gets it to open immediately
        markingMenu.open(locationInView)
        
        super.touchesBegan(touches, withEvent: event)
        
        state = UIGestureRecognizerState.Began
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

func applyDefaultMarkingMenuShadowToLayer(target: CALayer)
{
    target.shadowColor = UIColor.blackColor().CGColor
    target.shadowOffset = CGSize(width: 0, height: 0)
    target.shadowOpacity = 1
    target.shadowRadius = 2
}