//
//  JCCIWhiteBalance.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake Cai on 2019/4/9.
//  Copyright © 2019 Jake. All rights reserved.
//

import Cocoa

class JCCIWhiteBalance: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputTint: CGFloat = 0
    @objc dynamic var inputTemperature: CGFloat = 6500
    
    override func setDefaults() {
        inputTint = 0
        inputTemperature = 6500
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeDisplayName : "White Balance",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputTint": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "NSNumber",
                            kCIAttributeDisplayName: "Tint",
                            kCIAttributeDefault: 0,
                            kCIAttributeSliderMax: 600.0,
                            kCIAttributeSliderMin: -600.0,
                            kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputTemperature": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "NSNumber",
                                 kCIAttributeDisplayName: "Temperature",
                                 kCIAttributeDefault: 6500.0,
                                 kCIAttributeSliderMin: 2000.0,
                                 kCIAttributeSliderMax: 20000.0,
                                 kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    private let filter: CIFilter? = CIFilter(name: "CITemperatureAndTint")
    
    override var outputImage: CIImage? {
        guard let filter = filter,
            let image = inputImage else {
                return inputImage
        }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: inputTemperature, y: inputTint), forKey: "inputTargetNeutral")
        return filter.outputImage
    }
}
