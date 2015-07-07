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
     
        let markingMenuOrigin = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        markingMenuContentViewController = FMMarkingMenuContentViewController(origin: markingMenuOrigin)
        
        self.viewController = viewController
        self.view = view
        self.view.userInteractionEnabled = true
        
        super.init();
        
        markingMenuContentViewController.markingMenu = self
        
        tap = FMMarkingMenuPanGestureRecognizer(target: self, action: "tapHandler:")
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
            open(recognizer.locationInView(view))
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
    
    private func open(locationInView: CGPoint)
    {
        markingMenuContentViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        markingMenuContentViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        markingMenuContentViewController.view.frame = view.bounds
        
        markingMenuContentViewController.layoutMode = layoutMode
        
        viewController.presentViewController(markingMenuContentViewController, animated: false)
        {
            let markingMenuOrigin = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
            self.markingMenuContentViewController.origin = markingMenuOrigin
            self.markingMenuContentViewController.openMarkingMenu(locationInView, markingMenuItems: self.markingMenuItems)
        }
    }
}


