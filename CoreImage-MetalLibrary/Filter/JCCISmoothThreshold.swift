//
//  JCCISmoothThreshold.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/24.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCISmoothThreshold: CIFilter {
    @objc dynamic var inputImage : CIImage?
    @objc dynamic var inputEdgeO: CGFloat = 0.25
    @objc dynamic var inputEdge1: CGFloat = 0.75
    
    override func setDefaults() {
        inputEdgeO = 0.25
        inputEdge1 = 0.75
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Smooth Threshold Filter",
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            "inputEdgeO": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "NSNumber",
                           kCIAttributeDefault: 0.25,
                           kCIAttributeDisplayName: "Edge 0",
                           kCIAttributeMin: 0,
                           kCIAttributeSliderMin: 0,
                           kCIAttributeSliderMax: 1,
                           kCIAttributeType: kCIAttributeTypeScalar],
            "inputEdge1": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "NSNumber",
                           kCIAttributeDefault: 0.75,
                           kCIAttributeDisplayName: "Edge 1",
                           kCIAttributeMin: 0,
                           kCIAttributeSliderMin: 0,
                           kCIAttributeSliderMax: 1,
                           kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib") else {
                return nil
            }
            let data = try Data(contentsOf: url)
            let kernel = try CIColorKernel(functionName: "smoothThreshold", fromMetalLibraryData: data)
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
        return kernel.apply(extent: image.extent, arguments: [image, inputEdgeO, inputEdge1])
    }
}

class JCCIThreshold: CIFilter {
    @objc dynamic var inputImage : CIImage?
    @objc dynamic var inputThreshold: CGFloat = 0.75
    
    override func setDefaults() {
        inputThreshold = 0.75
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Threshold Filter",
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            "inputThreshold": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDefault: 0.75,
                               kCIAttributeDisplayName: "Threshold",
                               kCIAttributeMin: 0,
                               kCIAttributeSliderMin: 0,
                               kCIAttributeSliderMax: 1,
                               kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
                let data = JCCICustomFilter.sharedInstance.metallibData else {
                    return nil
            }
            let kernel = try CIColorKernel(functionName: "thresholdFilter", fromMetalLibraryData: data)
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
        return kernel.apply(extent: image.extent, arguments: [image, inputThreshold])
    }
}
