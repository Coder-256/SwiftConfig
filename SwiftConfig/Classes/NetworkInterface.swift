//
//  NetworkInterface.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

class NetworkInterface {
    let interface: SCNetworkInterface
    init(_ interface: SCNetworkInterface) {
        self.interface = interface
    }
    
    // MARK: Interface configuration
    
    static var all: [NetworkInterface]? {
        guard let arr = SCNetworkInterfaceCopyAll() as? [SCNetworkInterface] else { return nil }
        return arr.map { NetworkInterface($0) }
    }
    
    var supportedInterfaceTypes: CFArray? {
        return SCNetworkInterfaceGetSupportedInterfaceTypes(self.interface)
    }
    
    var supportedProtocolTypes: CFArray? {
        return SCNetworkInterfaceGetSupportedProtocolTypes(self.interface)
    }
    
    func with(interfaceTypeLayer: CFString) -> NetworkInterface? {
        guard let result = SCNetworkInterfaceCreateWithInterface(self.interface, interfaceTypeLayer) else { return nil }
        return NetworkInterface(result)
    }
    
    var bsdName: CFString? {
        return SCNetworkInterfaceGetBSDName(self.interface)
    }
    
    var configuration: CFDictionary? {
        get {
            return SCNetworkInterfaceGetConfiguration(self.interface)
        } set {
            SCNetworkInterfaceSetConfiguration(self.interface, newValue)
        }
    }
    
    func configuration(extendedType: CFString) -> CFDictionary? {
        return SCNetworkInterfaceGetExtendedConfiguration(self.interface, extendedType)
    }
    
    @discardableResult func setExtendedConfiguration(type extendedType: CFString, config: CFDictionary?) -> Bool {
        return SCNetworkInterfaceSetExtendedConfiguration(self.interface, extendedType, config)
    }
    
    var hardwareAddress: CFString? {
        return SCNetworkInterfaceGetHardwareAddressString(self.interface)
    }
    
    var underlying: NetworkInterface? {
        guard let result = SCNetworkInterfaceGetInterface(self.interface) else { return nil }
        return NetworkInterface(result)
    }
    
    var type: CFString? {
        return SCNetworkInterfaceGetInterfaceType(self.interface)
    }
    
    var localizedDisplayName: CFString? {
        return SCNetworkInterfaceGetLocalizedDisplayName(self.interface)
    }
    
    var mediaOptions: (current: CFDictionary, active: CFDictionary, available: CFArray)? {
        var current:   Unmanaged<CFDictionary>?
        var active:    Unmanaged<CFDictionary>?
        var available: Unmanaged<CFArray     >?
        guard SCNetworkInterfaceCopyMediaOptions(self.interface, &current, &active, &available, true) else { return nil }
        return (current:   current!  .takeRetainedValue(),
                active:    active!   .takeRetainedValue(),
                available: available!.takeRetainedValue())
    }
    
    var mediaSubTypes: CFArray? {
        guard let available = self.mediaOptions?.available else { return nil }
        return SCNetworkInterfaceCopyMediaSubTypes(available)
    }
    
    func mediaOptions(subType: CFString) -> CFArray? {
        guard let available = self.mediaOptions?.available else { return nil }
        return SCNetworkInterfaceCopyMediaSubTypeOptions(available, subType)
    }
    
    @discardableResult func setMediaOptions(subType: CFString, options: CFArray) -> Bool {
        return SCNetworkInterfaceSetMediaOptions(self.interface, subType, options)
    }
    
    var mtu: (mtu_cur: Int32, mtu_min: Int32, mtu_max: Int32)? {
        var mtu_cur: Int32 = 0
        var mtu_min: Int32 = 0
        var mtu_max: Int32 = 0
        guard SCNetworkInterfaceCopyMTU(self.interface, &mtu_cur, &mtu_min, &mtu_max) else { return nil }
        return (mtu_cur: mtu_cur,
                mtu_min: mtu_min,
                mtu_max: mtu_max)
    }
    
    var currentMTU: Int32? {
        get {
            return self.mtu?.mtu_cur
        } set {
            if let newValue = newValue {
                SCNetworkInterfaceSetMTU(self.interface, newValue)
            }
        }
    }
    
    func forceConfigurationRefresh() -> Bool {
        return SCNetworkInterfaceForceConfigurationRefresh(interface)
    }
}
