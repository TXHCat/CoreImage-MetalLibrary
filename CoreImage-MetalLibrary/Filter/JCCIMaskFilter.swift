//
//  JCCIMaskFilter.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake Cai on 2019/4/9.
//  Copyright © 2019 Jake. All rights reserved.
//

import Cocoa
import CoreImage

class JCCICircleMaskFilter: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputCenter: CIVector = CIVector(x: 300, y: 300)
    @objc dynamic var radius: CGFloat = 100.0
    @objc dynamic var reverse: Bool = false
    
    override func setDefaults() {
        reverse = false
        radius = 100.0
        inputCenter = CIVector(x: 300, y: 300)
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeDisplayName : "Circle Mask",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputCenter": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "CIVector",
                            kCIAttributeDisplayName: "Center",
                            kCIAttributeDefault: [300, 300],
                            kCIAttributeType: kCIAttributeTypePosition],
            
            "radius": [kCIAttributeIdentity: 0,
                       kCIAttributeClass: "NSNumber",
                       kCIAttributeDisplayName: "Radius",
                       kCIAttributeDefault: 100.0,
                       kCIAttributeType: kCIAttributeTypeDistance],
            
            "reverse": [kCIAttributeIdentity: 0,
                       kCIAttributeClass: "NSNumber",
                       kCIAttributeDisplayName: "Reverse",
                       kCIAttributeDefault: false,
                       kCIAttributeType: kCIAttributeTypeBoolean],
        ]
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIColorKernel(functionName: "maskForCircle",
                                           fromMetalLibraryData: data)
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
        return kernel.apply(extent: image.extent, arguments: [image, inputCenter, radius, reverse])
    }
}

class JCCIRectMaskFilter: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputCenter: CIVector = CIVector(x: 300, y: 300)
    @objc dynamic var inputAngle: CGFloat = 0
    @objc dynamic var inputSize: CIVector = CIVector(x: 100, y: 100)
    @objc dynamic var reverse: Bool = false
    
    override func setDefaults() {
        inputAngle = 0
        inputSize = CIVector(x: 100, y: 100)
        inputCenter = CIVector(x: 300, y: 300)
        reverse = false
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeDisplayName : "Circle Mask",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputCenter": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "CIVector",
                            kCIAttributeDisplayName: "Center",
                            kCIAttributeDefault: [300, 300],
                            kCIAttributeType: kCIAttributeTypePosition],
            
            "inputAngle": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "NSNumber",
                           kCIAttributeDisplayName: "Angle",
                           kCIAttributeDefault: 0,
                           kCIAttributeSliderMin: -CGFloat.pi,
                           kCIAttributeSliderMax: CGFloat.pi,
                           kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputSize": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "CIVector",
                          kCIAttributeDisplayName: "Size",
                          kCIAttributeDefault: [100, 100],
                          kCIAttributeType: kCIAttributeTypePosition],
            
            "reverse": [kCIAttributeIdentity: 0,
                        kCIAttributeClass: "NSNumber",
                        kCIAttributeDisplayName: "Reverse",
                        kCIAttributeDefault: false,
                        kCIAttributeType: kCIAttributeTypeBoolean],
        ]
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIColorKernel(functionName: "maskForRect",
                                           fromMetalLibraryData: data)
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
        return kernel.apply(extent: image.extent,
                            arguments: [image, inputCenter, inputAngle, inputSize, reverse])
    }
}

class JCCILinearMaskFilter: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputCenter: CIVector = CIVector(x: 300, y: 300)
    @objc dynamic var inputAngle: CGFloat = 0
    
    override func setDefaults() {
        inputAngle = 0
        inputCenter = CIVector(x: 300, y: 300)
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeDisplayName : "Circle Mask",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputCenter": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "CIVector",
                            kCIAttributeDisplayName: "Center",
                            kCIAttributeDefault: [100, 100],
                            kCIAttributeType: kCIAttributeTypePosition],
            
            "inputAngle": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "NSNumber",
                           kCIAttributeDisplayName: "Angle",
                           kCIAttributeDefault: 0,
                           kCIAttributeSliderMax: CGFloat.pi,
                           kCIAttributeSliderMin: -CGFloat.pi,
                           kCIAttributeType: kCIAttributeTypeAngle],
            
            "reverse": [kCIAttributeIdentity: 0,
                        kCIAttributeClass: "NSNumber",
                        kCIAttributeDisplayName: "Reverse",
                        kCIAttributeDefault: false,
                        kCIAttributeType: kCIAttributeTypeBoolean],
        ]
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIColorKernel(functionName: "maskForLinear",
                                           fromMetalLibraryData: data)
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
        return kernel.apply(extent: image.extent,
                            arguments: [image, inputCenter, inputAngle, CGFloat.pi])
    }
}
