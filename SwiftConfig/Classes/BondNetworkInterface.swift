//
//  BondNetworkInterface.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

open class BondNetworkInterface: NetworkInterface {
    open class Status {
        let status: SCBondStatus
        init(_ status: SCBondStatus) {
            self.status = status
        }
        
        func interfaceStatus(_ interface: SCBondInterface? = nil) -> CFDictionary? {
            return SCBondStatusGetInterfaceStatus(self.status, interface)
        }
        
        var memberInterfaces: [BondNetworkInterface]? {
            guard let arr = SCBondStatusGetMemberInterfaces(self.status) as? [SCBondInterface] else { return nil }
            return arr.map { BondNetworkInterface($0) }
        }
    }
    
    func remove() -> Bool {
        return SCBondInterfaceRemove(self.interface)
    }
    
    var status: Status? {
        guard let status = SCBondInterfaceCopyStatus(self.interface) else { return nil }
        return Status(status)
    }
    
    var memberInterfaces: [BondNetworkInterface]? {
        get {
            return SCBondInterfaceGetMemberInterfaces(self.interface) as? [BondNetworkInterface]
        } set {
            SCBondInterfaceSetMemberInterfaces(self.interface, (newValue ?? []) as CFArray)
        }
    }
    
    var options: CFDictionary? {
        get {
            return SCBondInterfaceGetOptions(self.interface)
        } set {
            SCBondInterfaceSetOptions(self.interface, newValue ?? [:] as CFDictionary)
        }
    }
    
    func setLocalizedDisplayName(_ name: CFString) {
        SCBondInterfaceSetLocalizedDisplayName(self.interface, name)
    }
}
