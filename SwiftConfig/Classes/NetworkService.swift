//
//  NetworkService.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

class NetworkService {
    let service: SCNetworkService
    init(_ service: SCNetworkService) {
        self.service = service
    }
    
    @discardableResult func addProtocolType(_ protocolType: CFString) -> Bool {
        return SCNetworkServiceAddProtocolType(self.service, protocolType)
    }
    
    var protocols: CFArray? {
        return SCNetworkServiceCopyProtocols(self.service)
    }
    
    func establishDefault() -> Bool {
        return SCNetworkServiceEstablishDefaultConfiguration(self.service)
    }
    
    var enabled: Bool {
        get {
            return SCNetworkServiceGetEnabled(self.service)
        } set {
            SCNetworkServiceSetEnabled(self.service, newValue)
        }
    }
    
    var interface: NetworkInterface? {
        guard let interface = SCNetworkServiceGetInterface(self.service) else { return nil }
        return NetworkInterface(interface)
    }
    
    var name: CFString? {
        get {
        return SCNetworkServiceGetName(self.service)
        } set {
            SCNetworkServiceSetName(self.service, name)
        }
    }
    
    func copyProtocol(protocolType: CFString) -> SCNetworkProtocol? {
        return SCNetworkServiceCopyProtocol(self.service, protocolType)
    }
    
    var serviceID: CFString? {
        return SCNetworkServiceGetServiceID(self.service)
    }
    
    func remove() -> Bool {
        return SCNetworkServiceRemove(self.service)
    }
    
    func remove(protocolType: CFString) -> Bool {
        return SCNetworkServiceRemoveProtocolType(self.service, protocolType)
    }
}
