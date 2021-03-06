//
//  CaptiveNetwork.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

open class CaptiveNetworkManager: Hashable, Equatable, CustomStringConvertible {
    public enum InterfaceError: Error {
        case unsupported
        case gotNil
    }

    private static func supportedNames() throws -> [CFString] {
        guard let names = CNCopySupportedInterfaces() as? [CFString] else { throw InterfaceError.gotNil }
        return names
    }

    open class func supportedInterfaces() throws -> [NetworkInterface] {
        let all = try NetworkInterface.all()
        return try CaptiveNetworkManager.supportedNames().lazy.compactMap { name in
            all.first { $0.bsdName() == name }
        }
    }

    open class func setSupportedSSIDs(_ newValue: [String]) -> Bool {
        return CNSetSupportedSSIDs(newValue as CFArray)
    }

    public let interface: NetworkInterface
    private let interfaceName: CFString

    public init(interface: NetworkInterface) throws {
        guard let name = interface.bsdName(),
            try CaptiveNetworkManager.supportedNames().contains(name) else { throw InterfaceError.unsupported }
        self.interface = interface
        self.interfaceName = name
    }

    open func setPortal(online: Bool) -> Bool {
        if online {
            return CNMarkPortalOnline(self.interfaceName)
        } else {
            return CNMarkPortalOffline(self.interfaceName)
        }
    }

    open var hashValue: Int {
        return self.interface.hashValue
    }

    public static func == (lhs: CaptiveNetworkManager, rhs: CaptiveNetworkManager) -> Bool {
        return lhs.interface == rhs.interface
    }

    open var description: String {
        if let interfaceDescription = CFCopyDescription(self.interface) as String? {
            return "CaptiveNetwork(interface: \(interfaceDescription))"
        }
        return String(describing: self.interface)
    }
}
