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
    
    open var supportedInterfaceTypes: [CFString]? {
        return SCNetworkInterfaceGetSupportedInterfaceTypes(self.interface) as? [CFString]
    }
    
    open var supportedProtocolTypes: [CFString]? {
        return SCNetworkInterfaceGetSupportedProtocolTypes(self.interface) as? [CFString]
    }
    
    open func with(interfaceLayerType: CFString) -> NetworkInterface? {
        guard let result = SCNetworkInterfaceCreateWithInterface(self.interface, interfaceLayerType) else { return nil }
        return NetworkInterface(result)
    }
    
    open var bsdName: String? {
        return SCNetworkInterfaceGetBSDName(self.interface) as String?
    }
    
    open var configuration: [CFString: CFPropertyList]? {
        get {
            return SCNetworkInterfaceGetConfiguration(self.interface) as? [CFString: CFPropertyList]
        } set {
            SCNetworkInterfaceSetConfiguration(self.interface, newValue as CFDictionary?)
        }
    }
    
    open func configuration(extendedType: CFString) -> [CFString: CFPropertyList]? {
        return SCNetworkInterfaceGetExtendedConfiguration(self.interface, extendedType) as? [CFString: CFPropertyList]
    }
    
    @discardableResult open func setExtendedConfiguration(type: CFString, config: [CFString: CFPropertyList]?) -> Bool {
        return SCNetworkInterfaceSetExtendedConfiguration(self.interface, type, config as CFDictionary?)
    }
    
    open var hardwareAddress: String? {
        return SCNetworkInterfaceGetHardwareAddressString(self.interface) as String?
    }
    
    open var underlying: NetworkInterface? {
        guard let result = SCNetworkInterfaceGetInterface(self.interface) else { return nil }
        return NetworkInterface(result)
    }
    
    open var type: CFString? {
        return SCNetworkInterfaceGetInterfaceType(self.interface)
    }
    
    open var localizedDisplayName: String? {
        return SCNetworkInterfaceGetLocalizedDisplayName(self.interface) as String?
    }
    
    open var mediaOptions: (current: [CFString: CFPropertyList], active: [CFString: CFPropertyList], available: [CFString])? {
        var current:   Unmanaged<CFDictionary>?
        var active:    Unmanaged<CFDictionary>?
        var available: Unmanaged<CFArray     >?
        guard SCNetworkInterfaceCopyMediaOptions(self.interface, &current, &active, &available, true) else { return nil }
        return (current:   current!  .takeRetainedValue() as! [CFString: CFPropertyList],
                active:    active!   .takeRetainedValue() as! [CFString: CFPropertyList],
                available: available!.takeRetainedValue() as! [CFString])
    }
    
    open var mediaSubTypes: [CFString]? {
        guard let available = self.mediaOptions?.available else { return nil }
        return SCNetworkInterfaceCopyMediaSubTypes(available as CFArray) as? [CFString]
    }
    
    open func mediaOptions(subType: CFString) -> [CFString]? {
        guard let available = self.mediaOptions?.available else { return nil }
        return SCNetworkInterfaceCopyMediaSubTypeOptions(available as CFArray, subType) as? [CFString]
    }
    
    @discardableResult open func setMediaOptions(subType: CFString, options: [CFString]) -> Bool {
        return SCNetworkInterfaceSetMediaOptions(self.interface, subType, options as CFArray)
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
