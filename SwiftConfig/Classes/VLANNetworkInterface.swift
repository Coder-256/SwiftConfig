//
//  VLANNetworkInterface.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

open class VLANNetworkInterface: NetworkInterface {
    open static var availablePhysicalInterfaces: [NetworkInterface]! {
        return (SCVLANInterfaceCopyAvailablePhysicalInterfaces() as? [SCNetworkInterface])?
            .lazy.map { NetworkInterface($0) }
    }

    open func remove() throws {
        try SCVLANInterfaceRemove(self.interface)~
    }

    open func physical() -> NetworkInterface! {
        guard let result = SCVLANInterfaceGetPhysicalInterface(self.interface) else { return nil }
        return NetworkInterface(result)
    }

    open func tag() -> Int! {
        return (SCVLANInterfaceGetTag(self.interface) as NSNumber?)?.intValue
    }

    open func set(physical: NetworkInterface? = nil, tag tagValue: Int? = nil) throws {
        let tag: CFNumber
        if let tagValue = tagValue {
            tag = NSNumber(value: tagValue)
        } else {
            // swiftlint:disable:next force_unwrapping
            tag = SCVLANInterfaceGetTag(self.interface)!
        }

        try SCVLANInterfaceSetPhysicalInterfaceAndTag(self.interface, (physical ?? self.physical()).interface, tag)~
    }

    open func options() -> [CFString: CFPropertyList]? {
        return SCVLANInterfaceGetOptions(self.interface) as? [CFString: CFPropertyList]
    }

    open func setOptions(_ newValue: [CFString: CFPropertyList]) throws {
        try SCVLANInterfaceSetOptions(self.interface, newValue as CFDictionary)~
    }

    open func setLocalizedDisplayName(_ name: String) throws {
        try SCVLANInterfaceSetLocalizedDisplayName(self.interface, name as CFString)~
    }
}
