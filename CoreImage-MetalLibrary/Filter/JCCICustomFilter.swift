//
//  JCCICustomFilter.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/23.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

private let CategoryCustomFilters = "Custom Filters"

class JCCICustomFilter: NSObject, CIFilterConstructor {
    
    static let sharedInstance = JCCICustomFilter()
    private override init() {
        super.init()
    }
    
    private(set) lazy var metallibData: Data? = {
        guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib") else {
            return nil
        }
        let data = try? Data(contentsOf: url)
        return data
    }()
    
    static func registFilter() {
        
        CIFilter.registerName(NSStringFromClass(JCCIColorLookUp.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCILensFlareGenerator.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIAdvancedMonochrome.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIOpacityFilter.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIBleachBypass.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIRGBChannelCompositing.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIRGBChannelToneCurve.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCICarnivalMirror.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIKuwaharaFilter.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIChromaticAberration.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCITransverseChromaticAberration.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCICausticNoise.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCICausticRefraction.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIScatter.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCISmoothThreshold.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIThreshold.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCICRTFilter.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIVHSTrackingLines.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCICrossZoomTransition.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCICircleMaskFilter.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIRectMaskFilter.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCILinearMaskFilter.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIWhiteBalance.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIStarFieldGenerator.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCIChromaKey.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(NSStringFromClass(JCCISwipeTransition.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        CIFilter.registerName(NSStringFromClass(JCCICornerRadius.self),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
    }
    
    func filter(withName name: String) -> CIFilter? {
        guard let filterType = NSClassFromString(name) as? CIFilter.Type else {
            return nil
        }
        return filterType.init()
    }
}
