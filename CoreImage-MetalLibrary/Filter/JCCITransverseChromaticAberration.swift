//
//  JCCITransverseChromaticAberration.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/24.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCITransverseChromaticAberration: CIFilter {
    
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputBlur: CGFloat = 10
    @objc dynamic var inputFalloff: CGFloat = 0.2
    @objc dynamic var inputSamples: CGFloat = 10
    
    override func setDefaults() {
        inputBlur = 10
        inputFalloff = 0.2
        inputSamples = 10
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Transverse Chromatic Aberration",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputBlur": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDefault: 10,
                          kCIAttributeDisplayName: "Blur",
                          kCIAttributeMin: 0,
                          kCIAttributeSliderMin: 0,
                          kCIAttributeSliderMax: 40,
                          kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputFalloff": [kCIAttributeIdentity: 0,
                             kCIAttributeClass: "NSNumber",
                             kCIAttributeDefault: 0.2,
                             kCIAttributeDisplayName: "Falloff",
                             kCIAttributeMin: 0,
                             kCIAttributeSliderMin: 0,
                             kCIAttributeSliderMax: 0.5,
                             kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputSamples": [kCIAttributeIdentity: 0,
                             kCIAttributeClass: "NSNumber",
                             kCIAttributeDefault: 10,
                             kCIAttributeDisplayName: "Samples",
                             kCIAttributeMin: 5,
                             kCIAttributeSliderMin: 5,
                             kCIAttributeSliderMax: 40,
                             kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    private let metalKernel: CIKernel? = {
        do {
            guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
                let data = JCCICustomFilter.sharedInstance.metallibData else {
                    return nil
            }
            let kernel = try CIKernel(functionName: "transverseChromaticAberration", fromMetalLibraryData: data)
            return kernel
        }
        catch {
            return nil
        }
    }()
    
    override var outputImage: CIImage? {
        guard let kernel = metalKernel,
            let image = inputImage else {
            return nil
        }
        return kernel.apply(extent: image.extent, roiCallback: { (index, rect) -> CGRect in
            return rect.insetBy(dx: -1, dy: -1)
        }, arguments: [image,
                       CIVector(x: image.extent.width, y: image.extent.height),
                       inputSamples,
                       inputFalloff,
                       inputBlur])
    }
}
