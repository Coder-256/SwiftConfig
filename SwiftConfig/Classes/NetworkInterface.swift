//
//  NetworkInterface.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

open class NetworkInterface {
    open let interface: SCNetworkInterface
    public init(_ interface: SCNetworkInterface) {
        self.interface = interface
    }
    
    // MARK: Interface configuration
    
    open static var all: [NetworkInterface]? {
        guard let arr = SCNetworkInterfaceCopyAll() as? [SCNetworkInterface] else { return nil }
        return arr.map { NetworkInterface($0) }
    }
    
    open var supportedInterfaceTypes: CFArray? {
        return SCNetworkInterfaceGetSupportedInterfaceTypes(self.interface)
    }
    
    open var supportedProtocolTypes: CFArray? {
        return SCNetworkInterfaceGetSupportedProtocolTypes(self.interface)
    }
    
    open func with(interfaceTypeLayer: CFString) -> NetworkInterface? {
        guard let result = SCNetworkInterfaceCreateWithInterface(self.interface, interfaceTypeLayer) else { return nil }
        return NetworkInterface(result)
    }
    
    open var bsdName: CFString? {
        return SCNetworkInterfaceGetBSDName(self.interface)
    }
    
    open var configuration: CFDictionary? {
        get {
            return SCNetworkInterfaceGetConfiguration(self.interface)
        } set {
            SCNetworkInterfaceSetConfiguration(self.interface, newValue)
        }
    }
    
    open func configuration(extendedType: CFString) -> CFDictionary? {
        return SCNetworkInterfaceGetExtendedConfiguration(self.interface, extendedType)
    }
    
    @discardableResult open func setExtendedConfiguration(type extendedType: CFString, config: CFDictionary?) -> Bool {
        return SCNetworkInterfaceSetExtendedConfiguration(self.interface, extendedType, config)
    }
    
    open var hardwareAddress: CFString? {
        return SCNetworkInterfaceGetHardwareAddressString(self.interface)
    }
    
    open var underlying: NetworkInterface? {
        guard let result = SCNetworkInterfaceGetInterface(self.interface) else { return nil }
        return NetworkInterface(result)
    }
    
    open var type: CFString? {
        return SCNetworkInterfaceGetInterfaceType(self.interface)
    }
    
    open var localizedDisplayName: CFString? {
        return SCNetworkInterfaceGetLocalizedDisplayName(self.interface)
    }
    
    open var mediaOptions: (current: CFDictionary, active: CFDictionary, available: CFArray)? {
        var current:   Unmanaged<CFDictionary>?
        var active:    Unmanaged<CFDictionary>?
        var available: Unmanaged<CFArray     >?
        guard SCNetworkInterfaceCopyMediaOptions(self.interface, &current, &active, &available, true) else { return nil }
        return (current:   current!  .takeRetainedValue(),
                active:    active!   .takeRetainedValue(),
                available: available!.takeRetainedValue())
    }
    
    open var mediaSubTypes: CFArray? {
        guard let available = self.mediaOptions?.available else { return nil }
        return SCNetworkInterfaceCopyMediaSubTypes(available)
    }
    
    open func mediaOptions(subType: CFString) -> CFArray? {
        guard let available = self.mediaOptions?.available else { return nil }
        return SCNetworkInterfaceCopyMediaSubTypeOptions(available, subType)
    }
    
    @discardableResult open func setMediaOptions(subType: CFString, options: CFArray) -> Bool {
        return SCNetworkInterfaceSetMediaOptions(self.interface, subType, options)
    }
    
    open var mtu: (mtu_cur: Int32, mtu_min: Int32, mtu_max: Int32)? {
        var mtu_cur: Int32 = 0
        var mtu_min: Int32 = 0
        var mtu_max: Int32 = 0
        guard SCNetworkInterfaceCopyMTU(self.interface, &mtu_cur, &mtu_min, &mtu_max) else { return nil }
        return (mtu_cur: mtu_cur,
                mtu_min: mtu_min,
                mtu_max: mtu_max)
    }
    
    open var currentMTU: Int32? {
        get {
            return self.mtu?.mtu_cur
        } set {
            if let newValue = newValue {
                SCNetworkInterfaceSetMTU(self.interface, newValue)
            }
        }
    }
    
    open func forceConfigurationRefresh() -> Bool {
        return SCNetworkInterfaceForceConfigurationRefresh(interface)
    }
}
