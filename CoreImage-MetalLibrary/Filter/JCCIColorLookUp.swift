//
//  JCCIColorLookUp.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/15.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCIColorLookUp: CIFilter {
    
    @objc dynamic var inputImage: CIImage?
    @objc dynamic lazy var inputLUT: CIImage? = {
        guard let url = Bundle.main.url(forResource: "lookup_amatorka",
                                        withExtension: "png") else {
            return nil
        }
        return CIImage(contentsOf: url)
    }()
    @objc dynamic var inputIntensity: CGFloat = 1.0
    
    override func setDefaults() {
        if let url = Bundle.main.url(forResource: "lookup_amatorka",
                                     withExtension: "png")  {
            inputLUT = CIImage(contentsOf: url)
        }
        inputIntensity = 1.0
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeDisplayName : "Color Look Up",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputIntensity": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDefault: 1.0,
                               kCIAttributeDisplayName: "Intensity",
                               kCIAttributeMin: 0,
                               kCIAttributeSliderMin: 0,
                               kCIAttributeSliderMax: 1.0,
                               kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    private let metalKernel: CIKernel? = {
        do {
            guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
                let data = JCCICustomFilter.sharedInstance.metallibData else {
                    return nil
            }
            let kernel = try CIKernel(functionName: "commitLUT",
                                      fromMetalLibraryData: data)
            return kernel
        }
        catch {
            return nil
        }
    }()
    
    override var outputImage: CIImage? {
        guard let kernel = metalKernel,
            let image = inputImage,
            let lut = inputLUT else {
            return inputImage
        }
        return kernel.apply(extent: image.extent, roiCallback: { (index, dest) -> CGRect in
            if index == 0 {
                return dest
            }
            else {
                return lut.extent
            }
        }, arguments: [image, lut, inputIntensity])
    }
}
