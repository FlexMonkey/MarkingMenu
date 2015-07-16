//
//  ViewController.swift
//  MarkingMenu
//
//  Created by Simon Gladman on 07/06/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.


import UIKit

class ViewController: UIViewController, FMMarkingMenuDelegate
{
    let photo = CIImage(image: UIImage(named: "photo.jpg")!)
    let imageView = UIImageView()
    var markingMenu: FMMarkingMenu!

    
    var markingMenuItems: [FMMarkingMenuItem]!
    
    let brightnessSlider = FMMarkingMenuItem(label: "Brightness", valueSliderValue: 0.5)
    let saturationSlider = FMMarkingMenuItem(label: "Saturation", valueSliderValue: 0.5)
    let contrastSlider = FMMarkingMenuItem(label: "Contrast", valueSliderValue: 0.5)
    
    let blurAmountSlider = FMMarkingMenuItem(label: "Blur Amount", valueSliderValue: 0)
    let sharpenAmountSlider = FMMarkingMenuItem(label: "Sharpen Amount", valueSliderValue: 0.5)
    
    let queue = dispatch_queue_create("FilterUpdateQueue", nil)
    var busy =  false
    var changePending = false

    let colorControlsFilter = CIFilter(name: "CIColorControls")!
    var blurFilter: CIFilter = CIFilter(name: FilterNames.CIGaussianBlur.rawValue)!
    var sharpenFilter: CIFilter = CIFilter(name: FilterNames.CISharpenLuminance.rawValue)!
    var photoEffectFilter: CIFilter?
    var colorEffectFilter: CIFilter?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createMarkingMenu()
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        view.addSubview(imageView)
        
        updateFilters()
    }
    
    func FMMarkingMenuItemSelected(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem)
    {
        guard let category = FilterCategories(rawValue: markingMenuItem.category!),
            filterName = FilterNames(rawValue: markingMenuItem.label)?.rawValue else
        {
            return
        }
        
        FMMarkingMenu.setExclusivelySelected(markingMenuItem, markingMenuItems: markingMenuItems)
        
        switch category
        {
        case FilterCategories.Blur:
            
            if blurFilter.name != filterName && CIFilter.filterNamesInCategory(kCICategoryBlur).indexOf(filterName) >= 0
            {
                blurFilter = CIFilter(name: filterName)!
            }
            
        case FilterCategories.Sharpen:
            
            if sharpenFilter.name != filterName
            {
                sharpenFilter = CIFilter(name: filterName)!
            }
            
        case FilterCategories.PhotoEffect:
            
            if photoEffectFilter?.name != filterName && CIFilter.filterNamesInCategory(kCICategoryColorEffect).indexOf(filterName) >= 0
            {
                photoEffectFilter = CIFilter(name: filterName)!
            }
            else
            {
                photoEffectFilter = nil
            }
            
        case FilterCategories.ColorEffect:
            
            if colorEffectFilter?.name != filterName && CIFilter.filterNamesInCategory(kCICategoryColorEffect).indexOf(filterName) >= 0
            {
                colorEffectFilter = CIFilter(name: filterName)!
            }
            else
            {
                colorEffectFilter = nil
            }
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
    
    func executeFilters() -> UIImage
    {
        // Color controls...
        
        colorControlsFilter.setValue(photo, forKey: kCIInputImageKey)
        colorControlsFilter.setValue(-1 + brightnessSlider.valueSliderValue * 2, forKey: kCIInputBrightnessKey)
        colorControlsFilter.setValue(saturationSlider.valueSliderValue * 2, forKey: kCIInputSaturationKey)
        colorControlsFilter.setValue(contrastSlider.valueSliderValue * 2, forKey: kCIInputContrastKey)
        
        // Blur...
        let blurEffectImageData: CIImage
        if blurAmountSlider.valueSliderValue > 0.01
        {
            blurFilter.setValue(colorControlsFilter.valueForKey(kCIOutputImageKey), forKey: kCIInputImageKey)
            blurFilter.setValue(blurAmountSlider.valueSliderValue * 10, forKey: "inputRadius")
            
            blurEffectImageData = blurFilter.valueForKey(kCIOutputImageKey) as! CIImage!
        }
        else
        {
            blurEffectImageData = colorControlsFilter.valueForKey(kCIOutputImageKey) as! CIImage!
        }
        
        // Sharpen...
        let sharpenFilterImageData: CIImage
        if sharpenAmountSlider.valueSliderValue > 0.01
        {
            sharpenFilter.setValue(blurEffectImageData, forKey: kCIInputImageKey)
            
            if sharpenFilter.name == FilterNames.CISharpenLuminance.rawValue
            {
                sharpenFilter.setValue(sharpenAmountSlider.valueSliderValue * 10, forKey: "inputSharpness")
            }
            else if sharpenFilter.name == FilterNames.CIUnsharpMask.rawValue
            {
                sharpenFilter.setValue(sharpenAmountSlider.valueSliderValue * 10, forKey: "inputIntensity")
            }
            
            sharpenFilterImageData = sharpenFilter.valueForKey(kCIOutputImageKey) as! CIImage!
        }
        else
        {
            sharpenFilterImageData = blurEffectImageData
        }
        
        // Photo effects...
        
        let photoEffectImageData: CIImage
        if let ciPhotoEffectFilter = photoEffectFilter
        {
            ciPhotoEffectFilter.setValue(sharpenFilterImageData, forKey: kCIInputImageKey)
            photoEffectImageData = ciPhotoEffectFilter.valueForKey(kCIOutputImageKey) as! CIImage!
        }
        else
        {
            photoEffectImageData = sharpenFilterImageData
        }
        
        // Color effects...
        let colorEffectImageData: CIImage
        if let ciColorEffectFilter = colorEffectFilter
        {
            ciColorEffectFilter.setValue(photoEffectImageData, forKey: kCIInputImageKey)
            colorEffectImageData = ciColorEffectFilter.valueForKey(kCIOutputImageKey) as! CIImage!
        }
        else
        {
            colorEffectImageData = photoEffectImageData
        }
        
        // Final image...
        return UIImage(CIImage: colorEffectImageData)
        
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
            FMMarkingMenuItem(label: FilterNames.None.rawValue, category: FilterCategories.ColorEffect.rawValue, isSelected: true),
            FMMarkingMenuItem(label: FilterNames.CIColorInvert.rawValue, category: FilterCategories.ColorEffect.rawValue),
            FMMarkingMenuItem(label: FilterNames.CIFalseColor.rawValue, category: FilterCategories.ColorEffect.rawValue),
            FMMarkingMenuItem(label: FilterNames.CIColorPosterize.rawValue, category: FilterCategories.ColorEffect.rawValue),
            FMMarkingMenuItem(label: FilterNames.CISepiaTone.rawValue, category: FilterCategories.ColorEffect.rawValue)])
        
        let photoEffect = FMMarkingMenuItem(label: FilterCategories.PhotoEffect.rawValue, subItems:[
            FMMarkingMenuItem(label: FilterNames.None.rawValue, category: FilterCategories.PhotoEffect.rawValue, isSelected: true),
            FMMarkingMenuItem(label: FilterNames.CIPhotoEffectFade.rawValue, category: FilterCategories.PhotoEffect.rawValue),
            FMMarkingMenuItem(label: FilterNames.CIPhotoEffectInstant.rawValue, category: FilterCategories.PhotoEffect.rawValue),
            FMMarkingMenuItem(label: FilterNames.CIPhotoEffectNoir.rawValue, category: FilterCategories.PhotoEffect.rawValue),
            FMMarkingMenuItem(label: FilterNames.CIPhotoEffectTonal.rawValue, category: FilterCategories.PhotoEffect.rawValue),
            FMMarkingMenuItem(label: FilterNames.CIPhotoEffectTransfer.rawValue, category: FilterCategories.PhotoEffect.rawValue)])
        
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
    
    case None
    
    case CIPhotoEffectFade
    case CIPhotoEffectInstant
    case CIPhotoEffectNoir
    case CIPhotoEffectTonal
    case CIPhotoEffectTransfer
    
    case CIColorInvert
    case CIColorPosterize
    case CIFalseColor
    case CISepiaTone
}



