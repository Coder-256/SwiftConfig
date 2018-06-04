//
//  NetworkInterface.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

open class NetworkInterface: Hashable, Equatable, CustomStringConvertible {
    public let interface: SCNetworkInterface

    public init(_ interface: SCNetworkInterface) {
        self.interface = interface
    }

    // MARK: Interface configuration

    public static func all() throws -> [NetworkInterface] {
        return try (SCNetworkInterfaceCopyAll() as? [SCNetworkInterface])~.lazy.map { NetworkInterface($0) }
    }

    open func supportedInterfaceTypes() -> [CFString]? {
        return SCNetworkInterfaceGetSupportedInterfaceTypes(self.interface) as? [CFString]
    }

    open func supportedProtocolTypes() -> [CFString]? {
        return SCNetworkInterfaceGetSupportedProtocolTypes(self.interface) as? [CFString]
    }

    open func with(interfaceLayerType: CFString) throws -> NetworkInterface {
        return try NetworkInterface(SCNetworkInterfaceCreateWithInterface(self.interface, interfaceLayerType)~)
    }

    open func bsdName() -> CFString? {
        return SCNetworkInterfaceGetBSDName(self.interface)
    }

    open func configuration() throws -> [CFString: CFPropertyList] {
        return try SCNetworkInterfaceGetConfiguration(self.interface)%
    }

    open func setConfiguration(_ newValue: [CFString: CFPropertyList]?) throws {
        try SCNetworkInterfaceSetConfiguration(self.interface, newValue as CFDictionary?)~
    }

    open func configuration(extendedType: CFString) throws -> [CFString: CFPropertyList] {
        return try SCNetworkInterfaceGetExtendedConfiguration(self.interface, extendedType)%
    }

    open func setExtendedConfiguration(type: CFString, _ newValue: [CFString: CFPropertyList]?) throws {
        try SCNetworkInterfaceSetExtendedConfiguration(self.interface, type, newValue as CFDictionary?)~
    }

    open func hardwareAddress() -> String? {
        return SCNetworkInterfaceGetHardwareAddressString(self.interface) as String?
    }

    open func underlying() -> NetworkInterface? {
        guard let result = SCNetworkInterfaceGetInterface(self.interface) else { return nil }
        return NetworkInterface(result)
    }

    open func type() -> CFString! {
        return SCNetworkInterfaceGetInterfaceType(self.interface)
    }

    open func localizedDisplayName() -> String! {
        return SCNetworkInterfaceGetLocalizedDisplayName(self.interface) as String?
    }

    open func mediaOptions(filter: Bool = true) throws -> (current: [CFString: CFPropertyList],
        active: [CFString: CFPropertyList],
        available: [CFString]) {
            var current: Unmanaged<CFDictionary>?
            var active: Unmanaged<CFDictionary>?
            var available: Unmanaged<CFArray     >?
            try SCNetworkInterfaceCopyMediaOptions(self.interface, &current, &active, &available, filter)~
            return try (current:   (current?  .takeRetainedValue() as? [CFString: CFPropertyList])~,
                        active:    (active?   .takeRetainedValue() as? [CFString: CFPropertyList])~,
                        available: (available?.takeRetainedValue() as? [CFString])~)
    }

    open func mediaOptions(subType: CFString) throws -> [CFString] {
        return try SCNetworkInterfaceCopyMediaSubTypeOptions(try self.mediaOptions().available as CFArray, subType)%
    }

    open func setMediaOptions(subType: CFString, _ newValue: [CFString]) throws {
        try SCNetworkInterfaceSetMediaOptions(self.interface, subType, newValue as CFArray)~
    }

    open func mediaSubTypes() throws -> [CFString] {
        return try SCNetworkInterfaceCopyMediaSubTypes(self.mediaOptions().available as CFArray)%
    }

    open func mtu() throws -> (current: Int32, min: Int32, max: Int32) {
        // swiftlint:disable identifier_name
        var mtu_cur: Int32 = 0
        var mtu_min: Int32 = 0
        var mtu_max: Int32 = 0
        // swiftlint:enable identifier_name
        try SCNetworkInterfaceCopyMTU(self.interface, &mtu_cur, &mtu_min, &mtu_max)~
        return (current: mtu_cur,
                min: mtu_min,
                max: mtu_max)
    }

    open func setMTU(_ newValue: Int32) throws {
        try SCNetworkInterfaceSetMTU(self.interface, newValue)~
    }

    open func forceConfigurationRefresh() throws {
        try SCNetworkInterfaceForceConfigurationRefresh(interface)~
    }

    open func active() -> Bool {
        guard let bsdName = self.bsdName() else { return false }
        return _swiftconfig_check_active(bsdName as String)
    }

    open var hashValue: Int {
        return self.interface.hashValue
    }

    public static func == (lhs: NetworkInterface, rhs: NetworkInterface) -> Bool {
        return lhs.interface == rhs.interface
    }

    open var description: String {
        return CFCopyDescription(self.interface) as String? ?? String(describing: self.interface)
    }
}
