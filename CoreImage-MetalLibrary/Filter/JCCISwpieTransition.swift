//
//  JCCISwpieTransition.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake Cai on 2019/6/14.
//  Copyright © 2019 Jake. All rights reserved.
//

import Cocoa

class JCCISwipeTransition: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputTargetImage: CIImage?
    @objc dynamic var inputTime: CGFloat = 0.0
    @objc dynamic var inputAngle: CGFloat = 0.0
    
    override func setDefaults() {
        inputTime = 0.0
        inputAngle = 0.0
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeDisplayName : "White Balance",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputTargetImage": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "CIImage",
                                 kCIAttributeDisplayName: "Image",
                                 kCIAttributeType: kCIAttributeTypeImage],
            
            "inputTime": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDisplayName: "Time",
                          kCIAttributeDefault: 0,
                          kCIAttributeSliderMax: 1.0,
                          kCIAttributeSliderMin: 0.0,
                          kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputAngle": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "NSNumber",
                           kCIAttributeDisplayName: "Angle",
                           kCIAttributeDefault: 0,
                           kCIAttributeSliderMax: CGFloat.pi * 2.0,
                           kCIAttributeSliderMin: 0.0,
                           kCIAttributeType: kCIAttributeTypeAngle],
            
        ]
    }
    
    private let filter: CIFilter? = CIFilter(name: "CISwipeTransition")
    
    override var outputImage: CIImage? {
        guard let filter = filter,
            let image = inputImage,
            let targetImage = inputTargetImage else {
                return inputImage
        }
        filter.setValue(image, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(inputTime, forKey: "inputTime")
        filter.setValue(inputAngle, forKey: kCIInputAngleKey)
        let extent = CIVector(x: targetImage.extent.origin.x,
                              y: targetImage.extent.origin.y,
                              z: targetImage.extent.size.width,
                              w: targetImage.extent.size.height)
        filter.setValue(extent, forKey: "inputExtent")
        
        filter.setValue(targetImage.extent.size.width, forKey: "inputWidth")
        return filter.outputImage
    }
}
