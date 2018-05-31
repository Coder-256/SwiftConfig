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
        open let status: SCBondStatus
        public init(_ status: SCBondStatus) {
            self.status = status
        }
        
        open func interfaceStatus(_ interface: SCBondInterface? = nil) -> CFDictionary? {
            return SCBondStatusGetInterfaceStatus(self.status, interface)
        }
        
        open var memberInterfaces: [NetworkInterface]? {
            return (SCBondStatusGetMemberInterfaces(self.status) as? [SCBondInterface])?.map { NetworkInterface($0) }
        }
    }
    
    open func remove() -> Bool {
        return SCBondInterfaceRemove(self.interface)
    }
    
    open var status: Status? {
        guard let status = SCBondInterfaceCopyStatus(self.interface) else { return nil }
        return Status(status)
    }
    
    open var memberInterfaces: [NetworkInterface]? {
        get {
            return (SCBondInterfaceGetMemberInterfaces(self.interface) as? [SCNetworkInterface])?.map { NetworkInterface($0) }
        } set {
            SCBondInterfaceSetMemberInterfaces(self.interface, (newValue ?? []).map { $0.interface } as CFArray)
        }
    }
    
    open var options: CFDictionary? {
        get {
            return SCBondInterfaceGetOptions(self.interface)
        } set {
            SCBondInterfaceSetOptions(self.interface, newValue ?? [:] as CFDictionary)
        }
    }
    
    open func setLocalizedDisplayName(_ name: CFString) {
        SCBondInterfaceSetLocalizedDisplayName(self.interface, name)
    }
}
