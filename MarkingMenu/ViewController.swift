//
//  ViewController.swift
//  MarkingMenu
//
//  Created by Simon Gladman on 07/06/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
 
    let blur = FMMarkingMenuItem(label: "Blur & Sharpen", subItems:[FMMarkingMenuItem(label: "Gaussian Blur"), FMMarkingMenuItem(label: "Sharpen Luminance"), FMMarkingMenuItem(label: "Unsharp Mask")])
    let noFilter = FMMarkingMenuItem(label: "No Filter")
    let colorAdjust = FMMarkingMenuItem(label: "Color Adjust", subItems:[FMMarkingMenuItem(label: "Exposure"), FMMarkingMenuItem(label: "Gamma"), FMMarkingMenuItem(label: "Hue"), FMMarkingMenuItem(label: "Temperature & Tint"), FMMarkingMenuItem(label: "Vibrance")])
    let colorEffect = FMMarkingMenuItem(label: "Color Effect", subItems:[FMMarkingMenuItem(label: "Invert"), FMMarkingMenuItem(label: "Monochrome"), FMMarkingMenuItem(label: "Posterize"), FMMarkingMenuItem(label: "False Color"), FMMarkingMenuItem(label: "Sepia")])
    let photoEffect = FMMarkingMenuItem(label: "Photo Effect", subItems:[FMMarkingMenuItem(label: "Chrome"), FMMarkingMenuItem(label: "Fade"), FMMarkingMenuItem(label: "Instant"), FMMarkingMenuItem(label: "Noir"), FMMarkingMenuItem(label: "Tonal"), FMMarkingMenuItem(label: "Transfer")])
    let halftone = FMMarkingMenuItem(label: "Halftone", subItems:[FMMarkingMenuItem(label: "Circular Screen"), FMMarkingMenuItem(label: "Dot Screen"), FMMarkingMenuItem(label: "Hatched Screen"), FMMarkingMenuItem(label: "Line Screen")])
    let styleize = FMMarkingMenuItem(label: "Stylize", subItems:[FMMarkingMenuItem(label: "Bloom"), FMMarkingMenuItem(label: "Gloom"), FMMarkingMenuItem(label: "Pixellate")])
    
    var markingMenu: FMMarkingMenu!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        

        
        let deepFilter = FMMarkingMenuItem(label: "Deep Menu", subItems: [blur, colorAdjust, colorEffect, photoEffect, halftone, styleize])
        
        let markingMenuItems = [blur, colorAdjust, colorEffect, photoEffect, halftone, styleize, noFilter, deepFilter]
        
        markingMenu = FMMarkingMenu(viewController: self, view: view, markingMenuItems: markingMenuItems)
    }
    
      
}




