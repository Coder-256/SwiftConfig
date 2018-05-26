//
//  ConfigContext.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

protocol ConfigContext {
    init(version: CFIndex, info: UnsafeMutableRawPointer?, retain: (@convention(c) (UnsafeRawPointer) -> UnsafeRawPointer)?, release: (@convention(c) (UnsafeRawPointer) -> Swift.Void)?, copyDescription: (@convention(c) (UnsafeRawPointer) -> Unmanaged<CFString>)?)
}

extension SCDynamicStoreContext: ConfigContext {}
extension SCPreferencesContext: ConfigContext {}
extension SCNetworkConnectionContext: ConfigContext {}
extension SCNetworkReachabilityContext: ConfigContext {}

class ConfigHelper<Class: AnyObject, Context: ConfigContext> {
    static func makeContext(_ instance: Class) -> Context {
        let info = UnsafeMutableRawPointer(Unmanaged.passRetained(instance).toOpaque())
        return Context(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
    }
    
    static func decodeContext(_ context: UnsafeMutableRawPointer) -> Class {
        return Unmanaged<Class>.fromOpaque(context).takeUnretainedValue()
    }
}
