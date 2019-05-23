//
//  JCCIChromaKey.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake Cai on 2019/5/23.
//  Copyright © 2019 Jake. All rights reserved.
//

import Cocoa

class JCCIChromaKey: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var thresholdSensitivity: CGFloat = 0.1
    @objc dynamic var smoothing: CGFloat = 0.1
    @objc dynamic var inputCenter = CIVector(x: 0, y: 0)
    
    override func setDefaults() {
        smoothing = 0.1
        thresholdSensitivity = 0.1
        inputCenter = CIVector(x: 0, y: 0)
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeDisplayName : "Chroma Key",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "thresholdSensitivity": [kCIAttributeIdentity: 0,
                                     kCIAttributeClass: "NSNumber",
                                     kCIAttributeDisplayName: "ThresholdSensitivity",
                                     kCIAttributeDefault: 0.1,
                                     kCIAttributeSliderMax: 1.0,
                                     kCIAttributeSliderMin: 0.0,
                                     kCIAttributeType: kCIAttributeTypeScalar],

            "smoothing": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDisplayName: "Smoothing",
                          kCIAttributeDefault: 0.1,
                          kCIAttributeSliderMax: 1.0,
                          kCIAttributeSliderMin: 0.0,
                          kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputCenter": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "CIVector",
                                 kCIAttributeDisplayName: "Center",
                                 kCIAttributeDefault: [0, 0],
                                 kCIAttributeType: kCIAttributeTypePosition],
        ]
    }
    
    private let metalKernel: CIKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIKernel(functionName: "chromaKey", fromMetalLibraryData: data)
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
        }, arguments: [image, inputCenter, thresholdSensitivity, smoothing])
    }
}
