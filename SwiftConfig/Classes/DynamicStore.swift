//
//  DynamicStore.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration
import SystemConfiguration.SCDynamicStoreCopyDHCPInfo

private func storeCallout(store: SCDynamicStore,
                          changedKeys: CFArray,
                          info: UnsafeMutableRawPointer?) {
    if let info = info, let changedKeys = changedKeys as? [DynamicStore.Key] {
        ConfigHelper<DynamicStore, SCDynamicStoreContext>.decodeContext(info).callout?(changedKeys)
    }
}

open class DynamicStore: Hashable, Equatable, CustomStringConvertible {
    public typealias Key = CFString
    public typealias Value = CFPropertyList

    private var _store: SCDynamicStore?
    private var _notificationKeys: [Key] = []
    // swiftlint:disable:next force_unwrapping
    public var store: SCDynamicStore { return self._store! }
    public var callout: (([Key]) -> Void)?

    public init(_ store: SCDynamicStore) {
        self._store = store
    }

    public init(name: CFString) throws {
        var context = ConfigHelper<DynamicStore, SCDynamicStoreContext>.makeContext(self)
        self._store = try SCDynamicStoreCreate(nil, name, storeCallout(store:changedKeys:info:), &context)~
    }

    public convenience init(name: String) throws {
        try self.init(name: name as CFString)
    }

    open func get(key: Key) throws -> Value {
        return try SCDynamicStoreCopyValue(self.store, key)~
    }

    open func set(key: Key, to value: Value?) throws {
        if let value = value {
            try SCDynamicStoreSetValue(self.store, key, value)~
        } else {
            try SCDynamicStoreRemoveValue(self.store, key)~
        }
    }

    open func notificationKeys() -> [Key] {
        return self._notificationKeys
    }

    open func setNotificationKeys(_ newValue: [Key]) throws {
        try SCDynamicStoreSetNotificationKeys(self.store, newValue as CFArray, nil)~
        self._notificationKeys = newValue
    }

    open func computerInfo() throws -> (name: String, encoding: CFStringEncoding) {
        // If name is not nil, the encoding should be updated, but set this default just in case
        var encoding = CFStringGetSystemEncoding()
        let name = try SCDynamicStoreCopyComputerName(self.store, &encoding)~ as String
        return (name: name, encoding: encoding)
    }

    open func consoleUser() throws -> (uid: uid_t?, gid: gid_t?, info: String) {
        var uid: uid_t = 0
        var gid: gid_t = 0
        let info = try SCDynamicStoreCopyConsoleUser(store, &uid, &gid)~ as String
        return (uid: uid, gid: gid, info: info)
    }

    open func localHostName() throws -> String {
        return try SCDynamicStoreCopyLocalHostName(store)~ as String
    }

    open func currentLocationIdentifier() throws -> CFString {
        return try SCDynamicStoreCopyLocation(store)~
    }

    open func proxies() -> [CFString: CFPropertyList]! {
        return SCDynamicStoreCopyProxies(store) as? [CFString: CFPropertyList]
    }

    open func key(domain: CFString, globalEntity: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkGlobalEntity(nil, domain, globalEntity)
    }

    open func keyInterface(domain: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkInterface(nil, domain)
    }

    open func key(domain: CFString, ifname: CFString, entity: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkInterfaceEntity(nil, domain, ifname, entity)
    }

    open func key(domain: CFString, serviceID: CFString, entity: CFString) -> Key {
        return SCDynamicStoreKeyCreateNetworkServiceEntity(nil, domain, serviceID, entity)
    }

    open func keyComputerName() -> Key {
        return SCDynamicStoreKeyCreateComputerName(nil)
    }

    open func keyConsoleUser() -> Key {
        return SCDynamicStoreKeyCreateConsoleUser(nil)
    }

    open func keyHostNames() -> Key {
        return SCDynamicStoreKeyCreateHostNames(nil)
    }

    open func keyLocation() -> Key {
        return SCDynamicStoreKeyCreateLocation(nil)
    }

    open func keyProxies() -> Key {
        return SCDynamicStoreKeyCreateProxies(nil)
    }

    // MARK: DHCP

    open class DHCPInfo {
        public let info: CFDictionary

        public init(_ info: CFDictionary) {
            self.info = info
        }

        open func getOptionData(code: UInt8) -> CFData? {
            return DHCPInfoGetOptionData(self.info, code)
        }

        open func leaseStart() -> CFDate? {
            return DHCPInfoGetLeaseStartTime(self.info)
        }

        open func leaseExpiration() -> CFDate? {
            return DHCPInfoGetLeaseExpirationTime(self.info)
        }
    }

    open func dhcpInfo(serviceID: CFString? = nil) throws -> DHCPInfo {
        return try DHCPInfo(SCDynamicStoreCopyDHCPInfo(self.store, serviceID)~)
    }

    open var hashValue: Int {
        return self.store.hashValue
    }

    public static func == (lhs: DynamicStore, rhs: DynamicStore) -> Bool {
        return lhs.store == rhs.store
    }

    open var description: String {
        return CFCopyDescription(self.store) as String? ?? String(describing: self.store)
    }
}
