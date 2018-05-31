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
    static var availablePhysicalInterfaces: [NetworkInterface]? {
        return (SCVLANInterfaceCopyAvailablePhysicalInterfaces() as? [SCNetworkInterface])?.map { NetworkInterface($0) }
    }
    
    func remove() {
        SCVLANInterfaceRemove(self.interface)
    }
    
    var physical: NetworkInterface? {
        get {
            guard let result = SCVLANInterfaceGetPhysicalInterface(self.interface) else { return nil }
            return NetworkInterface(result)
        } set {
            if let newValue = newValue, let tag = SCVLANInterfaceGetTag(self.interface) {
                SCVLANInterfaceSetPhysicalInterfaceAndTag(self.interface, newValue.interface, tag)
            }
        }
    }
    
    var tag: Int? {
        get {
            guard let number = SCVLANInterfaceGetTag(self.interface) else { return nil }
            return (number as NSNumber).intValue
        } set {
            if let newValue = newValue, let physical = self.physical {
                SCVLANInterfaceSetPhysicalInterfaceAndTag(self.interface, physical.interface, NSNumber(value: newValue) as CFNumber)
            }
        }
    }
    
    var options: [CFString: CFPropertyList]? {
        get {
            return SCVLANInterfaceGetOptions(self.interface) as? [CFString: CFPropertyList]
        } set {
            if let options = newValue {
                SCVLANInterfaceSetOptions(self.interface, options as CFDictionary)
            }
        }
    }
    
    func setLocalizedDisplayName(_ name: String) {
        SCVLANInterfaceSetLocalizedDisplayName(self.interface, name as CFString)
    }
}
