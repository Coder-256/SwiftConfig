//
//  VLANNetworkInterface.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

class VLANNetworkInterface: NetworkInterface {
    static var physicalInterfaces: [VLANNetworkInterface]? {
        guard let arr = SCVLANInterfaceCopyAvailablePhysicalInterfaces() as? [SCVLANInterface] else { return nil }
        return arr.map { VLANNetworkInterface($0) }
    }
    
    func remove() {
        SCVLANInterfaceRemove(self.interface)
    }
    
    var physical: VLANNetworkInterface? {
        get {
            guard let result = SCVLANInterfaceGetPhysicalInterface(self.interface) else { return nil }
            return VLANNetworkInterface(result)
        } set {
            if let newValue = newValue, let tag = self.tag {
                SCVLANInterfaceSetPhysicalInterfaceAndTag(self.interface, newValue.interface, tag)
            }
        }
    }
    
    var tag: CFNumber? {
        get {
            return SCVLANInterfaceGetTag(self.interface)
        } set {
            if let newValue = newValue, let physical = self.physical {
                SCVLANInterfaceSetPhysicalInterfaceAndTag(self.interface, physical.interface, newValue)
            }
        }
    }
    
    var options: CFDictionary? {
        get {
            return SCVLANInterfaceGetOptions(self.interface)
        } set {
            if let options = newValue {
                SCVLANInterfaceSetOptions(self.interface, options)
            }
        }
    }
    
    func setLocalizedDisplayName(_ name: CFString) {
        SCVLANInterfaceSetLocalizedDisplayName(self.interface, name)
    }
}
