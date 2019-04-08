//
//  JCCIScatterWrap.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/24.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCIScatter: CIFilter {
    
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputScatterRadius: CGFloat = 25
    @objc dynamic var inputScatterSmoothness: CGFloat = 1.0
    
    override func setDefaults() {
        inputScatterRadius = 25
        inputScatterSmoothness = 1.0
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Scatter",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputScatterRadius": [kCIAttributeIdentity: 0,
                                   kCIAttributeClass: "NSNumber",
                                   kCIAttributeDefault: 25,
                                   kCIAttributeDisplayName: "Scatter Radius",
                                   kCIAttributeMin: 1,
                                   kCIAttributeSliderMin: 1,
                                   kCIAttributeSliderMax: 150,
                                   kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputScatterSmoothness": [kCIAttributeIdentity: 0,
                                       kCIAttributeClass: "NSNumber",
                                       kCIAttributeDefault: 1,
                                       kCIAttributeDisplayName: "Scatter Smoothness",
                                       kCIAttributeMin: 0,
                                       kCIAttributeSliderMin: 0,
                                       kCIAttributeSliderMax: 4,
                                       kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    private let metalKernel: CIKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIKernel(functionName: "scatter", fromMetalLibraryData: data)
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
        guard let noise = CIFilter(name: "CIRandomGenerator")?.outputImage?
            .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: inputScatterSmoothness])
            .cropped(to: image.extent) else {
                return inputImage
        }
        return kernel.apply(extent: image.extent,
                            roiCallback:
            { (index, rect) -> CGRect in
                return rect
            },
                            arguments: [image, noise, inputScatterRadius])
    }
}
