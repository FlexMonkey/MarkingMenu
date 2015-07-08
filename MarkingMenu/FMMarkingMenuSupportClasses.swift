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

struct FMMarkingMenuItem
{
    let label: String
    let subItems: [FMMarkingMenuItem]?
    let isValueSlider:Bool // TODO menu items and sliders should be two distinct structs with a common protocol
    var valueSliderValue: CGFloat = 0.0
    
    init(label: String, subItems: [FMMarkingMenuItem]? = nil, isValueSlider: Bool = false)
    {
        self.label = label
        self.subItems = subItems
        self.isValueSlider = isValueSlider
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
    
    func FMMarkingMenuValueSliderChange(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem, markingMenuItemIndex: Int, newValue: CGFloat)
}

// An extended UIPanGestureRecognizer that fires UIGestureRecognizerState.Began
// with the first touch down, i.e. without requiring any movement.
class FMMarkingMenuPanGestureRecognizer: UIPanGestureRecognizer
{
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent)
    {
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