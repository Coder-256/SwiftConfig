//
//  ConfigPreferences.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

private func configCallout(prefs: SCPreferences,
                           notificationType: SCPreferencesNotification,
                           info: UnsafeMutableRawPointer?) {
    if let info = info {
        ConfigHelper<ConfigPreferences, SCPreferencesContext>.decodeContext(info).callout?(notificationType)
    }
}

open class ConfigPreferences: Hashable, Equatable {
    public typealias Key = CFString
    public typealias Value = CFPropertyList

    private var _prefs: SCPreferences?
    // swiftlint:disable:next force_unwrapping
    open var prefs: SCPreferences { return self._prefs! }
    open var callout: ((SCPreferencesNotification) -> Void)?

    public init(_ prefs: SCPreferences) {
        self._prefs = prefs
    }

    public init(name: CFString, prefsID: CFString? = nil, authorization auth: AuthorizationRef? = nil) throws {
        let result: SCPreferences?
        if let auth = auth {
            result = SCPreferencesCreateWithAuthorization(nil, name, prefsID, auth)
        } else {
            result = SCPreferencesCreate(nil, name, prefsID)
        }
        let prefs = try result~

        var context = ConfigHelper<ConfigPreferences, SCPreferencesContext>.makeContext(self)
        self._prefs = prefs
        SCPreferencesSetCallback(self.prefs, configCallout(prefs:notificationType:info:), &context)
    }

    public convenience init(name: String,
                            prefsID: CFString? = nil,
                            authorization auth: AuthorizationRef? = nil) throws {
        try self.init(name: name as CFString, prefsID: prefsID, authorization: auth)
    }

    open func commitChanges() throws {
        try SCPreferencesCommitChanges(self.prefs)~
    }

    open func applyChanges() throws {
        try SCPreferencesApplyChanges(self.prefs)~
    }

    open func withLock<T>(wait: Bool, block: () throws -> T) throws -> T {
        defer { SCPreferencesUnlock(self.prefs) }
        try SCPreferencesLock(self.prefs, wait)~
        return try block()
    }

    open func synchronize() {
        SCPreferencesSynchronize(self.prefs)
    }

    open func signature() throws -> Data {
        return try SCPreferencesGetSignature(self.prefs)~ as NSData as Data
    }

    open func keys() -> [Key]! {
        return SCPreferencesCopyKeyList(self.prefs) as? [Key]
    }

    open func get(key: Key) throws -> Value {
        return try SCPreferencesGetValue(self.prefs, key)~
    }

    open func set(key: Key, to value: Value?) throws {
        if let value = value {
            try SCPreferencesSetValue(self.prefs, key, value)~
        } else {
            try SCPreferencesRemoveValue(self.prefs, key)~
        }
    }

    open func get(path: CFString) throws -> [Key: CFPropertyList] {
        return try SCPreferencesPathGetValue(self.prefs, path)%
    }

    open func set(path: CFString, to value: [Key: CFPropertyList]?) throws {
        if let value = value {
            try SCPreferencesPathSetValue(self.prefs, path, value as CFDictionary)~
        } else {
            try SCPreferencesPathRemoveValue(self.prefs, path)~
        }
    }

    open func createUniqueChild(prefix: Key) throws -> Key {
        return try SCPreferencesPathCreateUniqueChild(self.prefs, prefix)~
    }

    open func getLink(path: Key) throws -> Key {
        return try SCPreferencesPathGetLink(self.prefs, path)~
    }

    open func setLink(path: Key, link: Key) throws {
        try SCPreferencesPathSetLink(self.prefs, path, link)~
    }

    open func serviceCreate(interface: NetworkInterface) throws -> NetworkService {
        return try NetworkService(SCNetworkServiceCreate(self.prefs, interface.interface)~)
    }

    open func serviceCopy(serviceID: CFString) throws -> NetworkService {
        return try NetworkService(SCNetworkServiceCopy(self.prefs, serviceID)~)
    }

    open func networkSetCreate() throws -> NetworkSet {
        return try NetworkSet(SCNetworkSetCreate(self.prefs)~)
    }

    open func networkSets() -> [NetworkSet]! {
        return (SCNetworkSetCopyAll(self.prefs) as? [SCNetworkSet])?.lazy.map { NetworkSet($0) }
    }

    open func currentNetworkSet() -> NetworkSet! {
        guard let result = SCNetworkSetCopyCurrent(self.prefs) else { return nil }
        return NetworkSet(result)
    }

    open func networkSet(setID: CFString) throws -> NetworkSet {
        return try NetworkSet(SCNetworkSetCopy(self.prefs, setID)~)
    }

    open var services: [NetworkService]! {
        return (SCNetworkServiceCopyAll(self.prefs) as? [SCNetworkService])?.lazy.map { NetworkService($0) }
    }

    open func setComputerName(name: CFString?, nameEncoding: CFStringEncoding) throws {
        try SCPreferencesSetComputerName(self.prefs, name, nameEncoding)~
    }

    open func setComputerName(name: String?, nameEncoding: CFStringEncoding) throws {
        try self.setComputerName(name: name as CFString?, nameEncoding: nameEncoding)
    }

    open func setLocalHostName(name: CFString?) throws {
        try SCPreferencesSetLocalHostName(self.prefs, name)~
    }

    open func setLocalHostName(name: String?) throws {
        try self.setLocalHostName(name: name as CFString?)
    }

    // MARK: Bond

    open func bondInterfaces() -> [BondNetworkInterface]! {
        return (SCBondInterfaceCopyAll(self.prefs) as? [SCBondInterface])?.lazy.map { BondNetworkInterface($0) }
    }

    open var availableBondMemberInterfaces: [NetworkInterface]! {
        return (SCBondInterfaceCopyAvailableMemberInterfaces(self.prefs) as? [SCNetworkInterface])?
            .lazy.map { NetworkInterface($0) }
    }

    open func bondCreate() throws -> BondNetworkInterface {
        return try BondNetworkInterface(SCBondInterfaceCreate(self.prefs)~)
    }

    // MARK: VLAN

    open var vlanInterfaces: [VLANNetworkInterface]! {
        return (SCVLANInterfaceCopyAll(self.prefs) as? [SCVLANInterface])?.lazy.map { VLANNetworkInterface($0) }
    }

    open func vlanCreate(physical: VLANNetworkInterface, tag: CFNumber) throws -> VLANNetworkInterface {
        return try VLANNetworkInterface(SCVLANInterfaceCreate(self.prefs, physical.interface, tag)~)
    }

    open var hashValue: Int {
        return self.prefs.hashValue
    }

    open static func == (lhs: ConfigPreferences, rhs: ConfigPreferences) -> Bool {
        return lhs.prefs == rhs.prefs
    }
}
