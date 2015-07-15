//
//  FMMarkingMenu.swift
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

import UIKit

class FMMarkingMenu: NSObject
{
    let markingMenuContentViewController: FMMarkingMenuContentViewController
        
    var markingMenuItems:[FMMarkingMenuItem]
    
    let viewController: UIViewController
    let view: UIView
    
    var tap: FMMarkingMenuPanGestureRecognizer!
    var previousTouchLocation = CGPointZero
    
    var layoutMode = FMMarkingMenuLayoutMode.SemiCircular
    var launchMode = FMMarkingMenuLaunchMode.OpenAtTouchLocation
    
    weak var markingMenuDelegate: FMMarkingMenuDelegate?
    {
        didSet
        {
            markingMenuContentViewController.markingMenuDelegate = markingMenuDelegate
        }
    }
    
    init(viewController: UIViewController, view: UIView, markingMenuItems:[FMMarkingMenuItem])
    {
        self.markingMenuItems = markingMenuItems
     
        markingMenuContentViewController = FMMarkingMenuContentViewController()
        
        self.viewController = viewController
        self.view = view
        self.view.userInteractionEnabled = true
        
        super.init();
        
        markingMenuContentViewController.markingMenu = self
        
        tap = FMMarkingMenuPanGestureRecognizer(target: self, action: "tapHandler:", markingMenu: self)

        view.addGestureRecognizer(tap)
    }
    
    deinit
    {
        viewController.view.removeGestureRecognizer(tap)
    }
    
    func tapHandler(recognizer: FMMarkingMenuPanGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            // nothing to do here, FMMarkingMenuPanGestureRecognizer
            // invokes open() on touchesBegan
        }
        else if recognizer.state == UIGestureRecognizerState.Changed
        {
            markingMenuContentViewController.handleMovement(recognizer.locationInView(view))
        }
        else
        {
           close()
        }
    }
    
    func close()
    {
        markingMenuContentViewController.closeMarkingMenu()
        viewController.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func open(locationInView: CGPoint)
    {        
        markingMenuContentViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        markingMenuContentViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        markingMenuContentViewController.view.frame = view.bounds
        
        markingMenuContentViewController.layoutMode = layoutMode
        
        viewController.presentViewController(markingMenuContentViewController, animated: false)
        {
            let markingMenuOrigin: CGPoint
            
            if self.launchMode == .OpenAtScreenCentre
            {
                markingMenuOrigin = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
            }
            else
            {
                markingMenuOrigin = locationInView
            }
            
            self.markingMenuContentViewController.origin = markingMenuOrigin
            self.markingMenuContentViewController.openMarkingMenu(locationInView, markingMenuItems: self.markingMenuItems)
        }
    }
    
    // MARK: Utilities...
    
    static func setExclusivelySelected(markingMenuItem: FMMarkingMenuItem, markingMenuItems: [FMMarkingMenuItem])
    {
        let items = getMenuItemsByCategory(markingMenuItem.category!, markingMenuItems: markingMenuItems)
        
        for item in items where item !== markingMenuItem
        {
            item.isSelected = false
        }
        
        markingMenuItem.isSelected = true
    }
    
    static func getMenuItemsByCategory(category:String, markingMenuItems: [FMMarkingMenuItem]) -> [FMMarkingMenuItem]
    {
        var returnArray = [FMMarkingMenuItem]()
        
        for item in markingMenuItems
        {
            if item.category == category
            {
                returnArray.append(item)
            }
            
            if let subItems = item.subItems
            {
                returnArray.extend(FMMarkingMenu.getMenuItemsByCategory(category, markingMenuItems: subItems))
            }
        }
        
        return returnArray
    }
}


