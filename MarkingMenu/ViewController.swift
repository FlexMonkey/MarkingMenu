//
//  ViewController.swift
//  MarkingMenu
//
//  Created by Simon Gladman on 07/06/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//
// check nested value sliders!

import UIKit

class ViewController: UIViewController, FMMarkingMenuDelegate
{
    let photo = UIImage(named: "photo.jpg")!
    let imageView = UIImageView()
    var markingMenu: FMMarkingMenu!
    
    let ciContextFast = CIContext(EAGLContext: EAGLContext(API: EAGLRenderingAPI.OpenGLES2), options: [kCIContextWorkingColorSpace: NSNull()])
    
    let currentFilterLabel = UILabel()
    var filterName: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createMarkingMenu()
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        view.addSubview(imageView)
        view.addSubview(currentFilterLabel)
        
        imageView.image = photo
    }
    
    func FMMarkingMenuItemSelected(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem)
    {
        if markingMenuItem.category != nil
        {
            FMMarkingMenu.setExclusivelySelected(markingMenuItem, markingMenuItems: markingMenuItems)
        }
    }
    

    
    func FMMarkingMenuValueSliderChange(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem, newValue: CGFloat)
    {

    }

    var markingMenuItems: [FMMarkingMenuItem]!
    
    func createMarkingMenu()
    {
        let blurAmountSlider = FMMarkingMenuItem(label: "Blur Amount", valueSliderValue: 0.5)
        
        let blurTopLevel = FMMarkingMenuItem(label: FilterCategories.Blur.rawValue, subItems:[
            FMMarkingMenuItem(label: "Gaussian", category: FilterCategories.Blur.rawValue, isSelected: true),
            FMMarkingMenuItem(label: "Tent", category: FilterCategories.Blur.rawValue),
            FMMarkingMenuItem(label: "Box", category: FilterCategories.Blur.rawValue),
            blurAmountSlider])
    
        // --
        
        let sharpenAmountSlider = FMMarkingMenuItem(label: "Sharpen Amount", valueSliderValue: 0.5)
        
        let sharpenTopLevel = FMMarkingMenuItem(label: FilterCategories.Sharpen.rawValue, subItems:[
            FMMarkingMenuItem(label: "Sharpen Luminance", category: FilterCategories.Sharpen.rawValue, isSelected: true),
            FMMarkingMenuItem(label: "Unsharp Mask", category: FilterCategories.Sharpen.rawValue),
            sharpenAmountSlider])
    
        // --
        
        let colorEffect = FMMarkingMenuItem(label: FilterCategories.ColorEffect.rawValue, subItems:[
            FMMarkingMenuItem(label: "None", category: FilterCategories.ColorEffect.rawValue, isSelected: true),
            FMMarkingMenuItem(label: "Invert", category: FilterCategories.ColorEffect.rawValue),
            FMMarkingMenuItem(label: "Monochrome", category: FilterCategories.ColorEffect.rawValue),
            FMMarkingMenuItem(label: "Posterize", category: FilterCategories.ColorEffect.rawValue),
            FMMarkingMenuItem(label: "False Color", category: FilterCategories.ColorEffect.rawValue),
            FMMarkingMenuItem(label: "Sepia Tone", category: FilterCategories.ColorEffect.rawValue)])
        
        let photoEffect = FMMarkingMenuItem(label: FilterCategories.PhotoEffect.rawValue, subItems:[
            FMMarkingMenuItem(label: "None", category: FilterCategories.PhotoEffect.rawValue, isSelected: true),
            FMMarkingMenuItem(label: "Chrome", category: FilterCategories.PhotoEffect.rawValue),
            FMMarkingMenuItem(label: "Fade", category: FilterCategories.PhotoEffect.rawValue),
            FMMarkingMenuItem(label: "Instant", category: FilterCategories.PhotoEffect.rawValue),
            FMMarkingMenuItem(label: "Noir", category: FilterCategories.PhotoEffect.rawValue),
            FMMarkingMenuItem(label: "Tonal", category: FilterCategories.PhotoEffect.rawValue),
            FMMarkingMenuItem(label: "Transfer", category: FilterCategories.PhotoEffect.rawValue)])

        let brightness = FMMarkingMenuItem(label: "Brightness", valueSliderValue: 0)
        let saturation = FMMarkingMenuItem(label: "Saturation", valueSliderValue: 0.75)
        let contrast = FMMarkingMenuItem(label: "Contrast", valueSliderValue: 1)
        
        let colorTransformTopLevel = FMMarkingMenuItem(label: "Color Adjust", subItems: [brightness, saturation, contrast, photoEffect, colorEffect])
        
        // --
        
        let halftoneTopLevel = FMMarkingMenuItem(label: FilterCategories.Halftone.rawValue, subItems:[
            FMMarkingMenuItem(label: "None", category: FilterCategories.Halftone.rawValue, isSelected: true),
            FMMarkingMenuItem(label: "CICircularScreen", category: FilterCategories.Halftone.rawValue),
            FMMarkingMenuItem(label: "CIDotScreen", category: FilterCategories.Halftone.rawValue),
            FMMarkingMenuItem(label: "CIHatchedScreen", category: FilterCategories.Halftone.rawValue),
            FMMarkingMenuItem(label: "CILineScreen", category: FilterCategories.Halftone.rawValue)])

        markingMenuItems = [blurTopLevel, sharpenTopLevel, colorTransformTopLevel, halftoneTopLevel]
        
        markingMenu = FMMarkingMenu(viewController: self, view: view, markingMenuItems: markingMenuItems)
        
        markingMenu.markingMenuDelegate = self
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        imageView.frame = view.bounds.rectByInsetting(dx: 30, dy: 30)
    }
    
}

enum FilterCategories: String
{
    case Halftone
    case PhotoEffect = "Photo Effect"
    case ColorEffect = "Color Effect"
    case Sharpen
    case Blur
}



