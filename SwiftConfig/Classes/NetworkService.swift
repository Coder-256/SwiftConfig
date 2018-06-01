//
//  NetworkService.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

open class NetworkService {
    open let service: SCNetworkService
    public init(_ service: SCNetworkService) {
        self.service = service
    }
    
    open func addProtocolType(_ protocolType: CFString) throws {
        try SCNetworkServiceAddProtocolType(self.service, protocolType)~
    }
    
    open func protocols() throws -> [NetworkProtocol] {
        return try (SCNetworkServiceCopyProtocols(self.service) as? [SCNetworkProtocol])%.map { NetworkProtocol($0) }
    }
    
    open func establishDefault() throws {
        try SCNetworkServiceEstablishDefaultConfiguration(self.service)~
    }
    
    open func enabled() -> Bool {
        return SCNetworkServiceGetEnabled(self.service)
    }
    
    open func setEnabled(_ newValue: Bool) throws {
        try SCNetworkServiceSetEnabled(self.service, newValue)~
    }
    
    open func interface() throws -> NetworkInterface {
        return try NetworkInterface(SCNetworkServiceGetInterface(self.service)~)
    }
    
    open func name() -> String? {
        return SCNetworkServiceGetName(self.service) as String?
    }
    
    open func setName(_ newValue: String?) throws {
        try SCNetworkServiceSetName(self.service, newValue as CFString?)~
    }
    
    open func copyProtocol(protocolType: CFString) throws -> NetworkProtocol {
        return try NetworkProtocol(SCNetworkServiceCopyProtocol(self.service, protocolType)~)
    }
    
    open var serviceID: CFString! {
        return SCNetworkServiceGetServiceID(self.service)
    }
    
    open func remove() throws {
        try SCNetworkServiceRemove(self.service)~
    }
    
    open func remove(protocolType: CFString) throws {
        try SCNetworkServiceRemoveProtocolType(self.service, protocolType)~
    }
}
