//
//  JCCICrossZoomTransition.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/25.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCICrossZoomTransition: CIFilter {
    @objc dynamic var inputImage : CIImage?
    @objc dynamic var inputTargetImage: CIImage?
    @objc dynamic var inputStrength: CGFloat = 0.3
    @objc dynamic var inputTime: CGFloat = 0
    
    override func setDefaults() {
        inputStrength = 0.3
        inputTime = 0
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeDisplayName : "Cross Zoom Transition",
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputTargetImage": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "CIImage",
                                 kCIAttributeDisplayName: "TargetImage",
                                 kCIAttributeType: kCIAttributeTypeImage],
            
            "inputStrength": [kCIAttributeIdentity: 1,
                              kCIAttributeClass: "NSNumber",
                              kCIAttributeDefault: 0.3,
                              kCIAttributeDisplayName: "Strength",
                              kCIAttributeMin: 0,
                              kCIAttributeSliderMin: 0,
                              kCIAttributeSliderMax: 1.0,
                              kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputTime": [kCIAttributeIdentity: 1,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDefault: 0,
                          kCIAttributeDisplayName: "Time",
                          kCIAttributeMin: 0,
                          kCIAttributeSliderMin: 0,
                          kCIAttributeSliderMax: 1.0,
                          kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    private let metalKernel: CIKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIKernel(functionName: "crossZoomTransition", fromMetalLibraryData: data)
            return kernel
        }
        catch {
            return nil
        }
    }()
    
    override var outputImage: CIImage? {
        guard let kernel = metalKernel,
            let image = inputImage,
            let target = inputTargetImage else {
            return inputImage
        }
        let inputExtent = image.extent.union(target.extent)
        return kernel.apply(extent: image.extent, roiCallback: { (index, rect) -> CGRect in
            return rect
        }, arguments: [image, target, inputStrength, CIVector(cgRect: inputExtent), inputTime])
    }
}
