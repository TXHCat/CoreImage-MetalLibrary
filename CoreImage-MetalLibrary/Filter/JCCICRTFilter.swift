//
//  JCCRTFilter.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/24.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCICRTFilter: CIFilter {
    
    @objc dynamic var inputImage : CIImage?
    @objc dynamic var inputPixelWidth: CGFloat = 8
    @objc dynamic var inputPixelHeight: CGFloat = 12
    @objc dynamic var inputBend: CGFloat = 3.2
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "CRT Filter",
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            "inputPixelWidth": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDefault: 8,
                                kCIAttributeDisplayName: "Pixel Width",
                                kCIAttributeMin: 0,
                                kCIAttributeSliderMin: 0,
                                kCIAttributeSliderMax: 20,
                                kCIAttributeType: kCIAttributeTypeScalar],
            "inputPixelHeight": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "NSNumber",
                                 kCIAttributeDefault: 12,
                                 kCIAttributeDisplayName: "Pixel Height",
                                 kCIAttributeMin: 0,
                                 kCIAttributeSliderMin: 0,
                                 kCIAttributeSliderMax: 20,
                                 kCIAttributeType: kCIAttributeTypeScalar],
            "inputBend": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDefault: 3.2,
                          kCIAttributeDisplayName: "Bend",
                          kCIAttributeMin: 0.5,
                          kCIAttributeSliderMin: 0.5,
                          kCIAttributeSliderMax: 10,
                          kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override func setDefaults(){
        inputPixelWidth = 8
        inputPixelHeight = 12
        inputBend = 3.2
    }
    
    private let colorFilter = CRTColorFilter()
    private let wrapFilter = CRTWarpFilter()
    private let vignette = CIFilter(name: "CIVignette",
                                    parameters: [kCIInputIntensityKey: 1.5,
                                                 kCIInputRadiusKey: 2])!
    
    override var outputImage: CIImage? {
        guard let image = inputImage else{
            return nil
        }
        
        colorFilter.inputImage = image
        colorFilter.pixelWidth = inputPixelWidth
        colorFilter.pixelHeight = inputPixelHeight
        wrapFilter.bend =  inputBend
        
        if let output = colorFilter.outputImage {
            vignette.setValue(output,
                              forKey: kCIInputImageKey)
            wrapFilter.inputImage = vignette.outputImage
            return wrapFilter.outputImage
        }
        return inputImage
    }
    
    class CRTColorFilter: CIFilter {
        var inputImage : CIImage?
        
        var pixelWidth: CGFloat = 8.0
        var pixelHeight: CGFloat = 12.0
        
        private let metalKernel: CIKernel? = {
            do {
                guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                    return nil
                }
                let kernel = try CIKernel(functionName: "crtColor", fromMetalLibraryData: data)
                return kernel
            }
            catch {
                return nil
            }
        }()
        
        override var outputImage: CIImage? {
            guard let kernel = metalKernel,
                let image = inputImage else {
                    return inputImage
            }
            return kernel.apply(extent: image.extent, roiCallback: { (index, rect) -> CGRect in
                return rect
            }, arguments: [image, pixelWidth, pixelHeight])
        }
    }
    
    class CRTWarpFilter: CIFilter {
        var inputImage : CIImage?
        var bend: CGFloat = 3.2
        
        private let metalKernel: CIWarpKernel? = {
            do {
                guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                    return nil
                }
                let kernel = try CIWarpKernel(functionName: "crtWarp", fromMetalLibraryData: data)
                return kernel
            }
            catch {
                return nil
            }
        }()
        
        override var outputImage: CIImage? {
            guard let kernel = metalKernel,
                let image = inputImage else {
                    return inputImage
            }
            return kernel.apply(extent: image.extent.insetBy(dx: -1, dy: -1), roiCallback: { (index, rect) -> CGRect in
                return rect
            }, image: image, arguments: [CIVector(x: image.extent.width, y: image.extent.height), bend])
        }
    }
}
