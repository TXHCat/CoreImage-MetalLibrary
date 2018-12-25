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
        
        CIFilter.registerName(JCCIColorLookUp.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCILensFlareGenerator.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCIAdvancedMonochrome.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCIOpacityFilter.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCIBleachBypass.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCIRGBChannelCompositing.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCIRGBChannelToneCurve.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCICarnivalMirror.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCIKuwaharaFilter.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCIChromaticAberration.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCITransverseChromaticAberration.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCICausticNoise.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCICausticRefraction.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCIScatter.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCISmoothThreshold.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCIThreshold.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCICRTFilter.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCIVHSTrackingLines.className(),
                              constructor: JCCICustomFilter.sharedInstance,
                              classAttributes: [:])
        
        CIFilter.registerName(JCCICrossZoomTransition.className(),
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
