//
//  NetworkSet.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

open class NetworkSet: Hashable, Equatable, CustomStringConvertible {
    public let set: SCNetworkSet

    public init(_ set: SCNetworkSet) {
        self.set = set
    }

    open func add(service: NetworkService) throws {
        try SCNetworkSetAddService(self.set, service.service)~
    }

    open func remove(service: NetworkService) throws {
        try SCNetworkSetRemoveService(self.set, service.service)~
    }

    open func contains(interface: NetworkInterface) throws {
        try SCNetworkSetContainsInterface(self.set, interface.interface)~
    }

    open func services() throws -> [NetworkService] {
        let arr = try (SCNetworkSetCopyServices(self.set) as? [SCNetworkService])%.lazy.map { NetworkService($0) }
        let order = try self.serviceOrder()
        return arr.lazy.sorted {
            guard let lhs = $0.serviceID(),
                let rhs = $1.serviceID(),
                let lIndex = order.index(of: lhs),
                let rIndex = order.index(of: rhs) else { return false }
            return lIndex < rIndex
        }
    }

    open func name() -> String? {
        return SCNetworkSetGetName(self.set) as String?
    }

    open func setName(_ newValue: String?) throws {
        try SCNetworkSetSetName(self.set, newValue as CFString?)~
    }

    open func setID() -> CFString! {
        return SCNetworkSetGetSetID(self.set)
    }

    open func serviceOrder() throws -> [CFString] {
        return try SCNetworkSetGetServiceOrder(self.set)%
    }

    open func setServiceOrder(_ newValue: [CFString]) {
        SCNetworkSetSetServiceOrder(self.set, newValue as CFArray)
    }

    open func makeCurrent() throws {
        try SCNetworkSetSetCurrent(self.set)~
    }

    open func remove() throws {
        try SCNetworkSetRemove(self.set)~
    }

    open var hashValue: Int {
        return self.set.hashValue
    }

    public static func == (lhs: NetworkSet, rhs: NetworkSet) -> Bool {
        return lhs.set == rhs.set
    }

    open var description: String {
        return CFCopyDescription(self.set) as String? ?? String(describing: self.set)
    }
}
