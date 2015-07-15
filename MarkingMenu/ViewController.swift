//
//  ViewController.swift
//  MarkingMenu
//
//  Created by Simon Gladman on 07/06/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.


import UIKit

class ViewController: UIViewController, FMMarkingMenuDelegate
{
    let photo = UIImage(named: "photo.jpg")!
    let imageView = UIImageView()
    var markingMenu: FMMarkingMenu!

    
    var markingMenuItems: [FMMarkingMenuItem]!
    
    let blurAmountSlider = FMMarkingMenuItem(label: "Blur Amount", valueSliderValue: 0)
    let brightnessSlider = FMMarkingMenuItem(label: "Brightness", valueSliderValue: 0)
    let saturationSlider = FMMarkingMenuItem(label: "Saturation", valueSliderValue: 0.75)
    let contrastSlider = FMMarkingMenuItem(label: "Contrast", valueSliderValue: 1)
    let sharpenAmountSlider = FMMarkingMenuItem(label: "Sharpen Amount", valueSliderValue: 0.5)
    
    let queue = dispatch_queue_create("FilterUpdateQueue", nil)
    var busy =  false
    var changePending = false

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createMarkingMenu()
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        view.addSubview(imageView)
        
        updateFilters()
    }
    
    var blurFilter: FilterNames = FilterNames.CIGaussianBlur
    var sharpenFilter: FilterNames = FilterNames.CISharpenLuminance
    var blurAmount: CGFloat = 0
    
    func FMMarkingMenuItemSelected(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem)
    {
        guard let category = FilterCategories(rawValue: markingMenuItem.category!),
            filterName = FilterNames(rawValue: markingMenuItem.label) else
        {
            return
        }
        
        FMMarkingMenu.setExclusivelySelected(markingMenuItem, markingMenuItems: markingMenuItems)
        
        if category == FilterCategories.Blur
        {
            blurFilter = filterName
        }
        else if category == FilterCategories.Sharpen
        {
            sharpenFilter = filterName
        }
        
        updateFilters()
    }
    
    func FMMarkingMenuValueSliderChange(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem, newValue: CGFloat)
    {
        updateFilters()
    }

    func updateFilters()
    {
        guard !busy else
        {
            changePending = true
    
            return
        }
        
        busy = true
        
        dispatch_async(queue)
        {
            let filteredImage = self.executeFilters()
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.busy = false
                self.imageView.image = filteredImage
                
                if self.changePending
                {
                    self.changePending = false
                    self.updateFilters()
                }
            }
        }
    }
    
    let colorControlsFilter = CIFilter(name: "CIColorControls")!
    var ciBlurFilter: CIFilter = CIFilter(name: "CIGaussianBlur")!
    var ciSharpenFilter: CIFilter = CIFilter(name: "CISharpenLuminance")!
    
    func executeFilters() -> UIImage
    {
        if ciBlurFilter.name != blurFilter.rawValue
        {
            ciBlurFilter = CIFilter(name: blurFilter.rawValue)!
        }
        
        ciBlurFilter.setValue(CIImage(image: photo), forKey: kCIInputImageKey)
        ciBlurFilter.setValue(blurAmountSlider.valueSliderValue * 10, forKey: "inputRadius")
        
        // --

        colorControlsFilter.setValue(ciBlurFilter.valueForKey(kCIOutputImageKey), forKey: kCIInputImageKey)
        colorControlsFilter.setValue(brightnessSlider.valueSliderValue, forKey: kCIInputBrightnessKey)
        colorControlsFilter.setValue(saturationSlider.valueSliderValue, forKey: kCIInputSaturationKey)
        colorControlsFilter.setValue(contrastSlider.valueSliderValue, forKey: kCIInputContrastKey)
        
        // --
        
        if ciSharpenFilter.name != sharpenFilter.rawValue
        {
            ciSharpenFilter = CIFilter(name: sharpenFilter.rawValue)!
        }
        
        ciSharpenFilter.setValue(colorControlsFilter.valueForKey(kCIOutputImageKey), forKey: kCIInputImageKey)
        
        if ciSharpenFilter.name == FilterNames.CISharpenLuminance.rawValue
        {
            ciSharpenFilter.setValue(sharpenAmountSlider.valueSliderValue * 10, forKey: "inputSharpness")
        }
        else if ciSharpenFilter.name == FilterNames.CIUnsharpMask.rawValue
        {
            ciSharpenFilter.setValue(sharpenAmountSlider.valueSliderValue * 10, forKey: "inputIntensity")
        }
        
        // --
        
        let filteredImageData = ciSharpenFilter.valueForKey(kCIOutputImageKey) as! CIImage!
        
        let filteredImage = UIImage(CIImage: filteredImageData)
        
        return filteredImage
    }
    
    
    func createMarkingMenu()
    {
        let blurTopLevel = FMMarkingMenuItem(label: FilterCategories.Blur.rawValue, subItems:[
            FMMarkingMenuItem(label: FilterNames.CIGaussianBlur.rawValue, category: FilterCategories.Blur.rawValue, isSelected: true),
            FMMarkingMenuItem(label: FilterNames.CIBoxBlur.rawValue, category: FilterCategories.Blur.rawValue),
            FMMarkingMenuItem(label: FilterNames.CIDiscBlur.rawValue, category: FilterCategories.Blur.rawValue),
            blurAmountSlider])
    
        // --
      
        let sharpenTopLevel = FMMarkingMenuItem(label: FilterCategories.Sharpen.rawValue, subItems:[
            FMMarkingMenuItem(label: FilterNames.CISharpenLuminance.rawValue, category: FilterCategories.Sharpen.rawValue, isSelected: true),
            FMMarkingMenuItem(label: FilterNames.CIUnsharpMask.rawValue, category: FilterCategories.Sharpen.rawValue),
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


        
        let colorTransformTopLevel = FMMarkingMenuItem(label: "Color Adjust", subItems: [
            brightnessSlider,
            saturationSlider,
            contrastSlider,
            photoEffect,
            colorEffect])
        
        // --
    
        markingMenuItems = [blurTopLevel, sharpenTopLevel, colorTransformTopLevel]
        
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

enum FilterNames: String
{
    case CIGaussianBlur
    case CIDiscBlur
    case CIBoxBlur
    
    case CISharpenLuminance
    case CIUnsharpMask
}



