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
    open class Status: Equatable, Hashable, CustomStringConvertible {
        public let status: SCBondStatus

        public init(_ status: SCBondStatus) {
            self.status = status
        }

        open func interfaceStatus(_ interface: BondNetworkInterface? = nil) -> CFDictionary! {
            return SCBondStatusGetInterfaceStatus(self.status, interface?.interface)
        }

        open func memberInterfaces() -> [NetworkInterface]! {
            return (SCBondStatusGetMemberInterfaces(self.status) as? [SCBondInterface])?
                .lazy.map { NetworkInterface($0) }
        }

        open var hashValue: Int {
            return self.status.hashValue
        }

        public static func == (lhs: BondNetworkInterface.Status, rhs: BondNetworkInterface.Status) -> Bool {
            return lhs.status == rhs.status
        }

        open var description: String {
            return CFCopyDescription(self.status) as String? ?? String(describing: self.status)
        }
    }

    open func remove() throws {
        try SCBondInterfaceRemove(self.interface)~
    }

    open func status() throws -> Status {
        return try Status(SCBondInterfaceCopyStatus(self.interface)~)
    }

    open func memberInterfaces() -> [NetworkInterface]! {
        return (SCBondInterfaceGetMemberInterfaces(self.interface) as? [SCNetworkInterface])?
            .lazy.map { NetworkInterface($0) }
    }

    open func setMemberInterfaces(_ newValue: [NetworkInterface]) throws {
        try SCBondInterfaceSetMemberInterfaces(self.interface, newValue.map { $0.interface } as CFArray)~
    }

    open func options() -> [CFString: CFPropertyList]! {
        return SCBondInterfaceGetOptions(self.interface) as? [CFString: CFPropertyList]
    }

    open func setOptions(_ newValue: [CFString: CFPropertyList]) throws {
        try SCBondInterfaceSetOptions(self.interface, newValue as CFDictionary)~
    }

    open func setLocalizedDisplayName(_ name: CFString) throws {
        try SCBondInterfaceSetLocalizedDisplayName(self.interface, name)~
    }
}
