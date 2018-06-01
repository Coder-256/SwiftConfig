//
//  ConfigPreferences.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

fileprivate func configCallout(prefs: SCPreferences, notificationType: SCPreferencesNotification, info: UnsafeMutableRawPointer?) {
    if let info = info {
        ConfigHelper<ConfigPreferences, SCPreferencesContext>.decodeContext(info).callout?(notificationType)
    }
}

open class ConfigPreferences {
    public typealias Key = CFString
    public typealias Value = CFPropertyList
    
    private var _prefs: SCPreferences? = nil
    open var prefs: SCPreferences { return self._prefs! }
    open var callout: ((SCPreferencesNotification) -> ())?
    public init(_ prefs: SCPreferences) {
        self._prefs = prefs
    }
    
    public init?(name: CFString, prefsID: CFString? = nil, authorization auth: AuthorizationRef? = nil) {
        let result: SCPreferences?
        if let auth = auth {
            result = SCPreferencesCreateWithAuthorization(nil, name, prefsID, auth)
        } else {
            result = SCPreferencesCreate(nil, name, prefsID)
        }
        guard let prefs = result else { return nil }
        
        var context = ConfigHelper<ConfigPreferences, SCPreferencesContext>.makeContext(self)
        self._prefs = prefs
        SCPreferencesSetCallback(self.prefs, configCallout(prefs:notificationType:info:), &context)
    }
    
    public convenience init?(name: String, prefsID: CFString? = nil, authorization auth: AuthorizationRef? = nil) {
        self.init(name: name as CFString, prefsID: prefsID, authorization: auth)
    }
    
    open func lock(wait: Bool) -> Bool {
        return SCPreferencesLock(self.prefs, wait)
    }
    
    open func commitChanges() -> Bool {
        return SCPreferencesCommitChanges(self.prefs)
    }
    
    open func applyChanges() -> Bool {
        return SCPreferencesApplyChanges(self.prefs)
    }
    
    @discardableResult open func unlock() -> Bool {
        return SCPreferencesUnlock(self.prefs)
    }
    
    open func withLock<T>(wait: Bool, block: () throws -> T) rethrows -> T? {
        if self.lock(wait: wait) {
            let result = try block()
            self.unlock()
            return result
        } else {
            return nil
        }
    }
    
    open func synchronize() {
        SCPreferencesSynchronize(self.prefs)
    }
    
    open var signature: Data? {
        return SCPreferencesGetSignature(self.prefs) as NSData? as Data?
    }
    
    open var keys: [Key]? {
        return SCPreferencesCopyKeyList(self.prefs) as? [Key]
    }
    
    open subscript(_ key: Key) -> Value? {
        get {
            return SCPreferencesGetValue(self.prefs, key)
        }
        set(value) {
            if let value = value {
                SCPreferencesSetValue(self.prefs, key, value)
            } else {
                SCPreferencesRemoveValue(self.prefs, key)
            }
        }
    }
    
    open subscript(path path: CFString) -> [Key: CFPropertyList]? {
        get {
            return SCPreferencesPathGetValue(self.prefs, path) as? [Key: CFPropertyList]
        }
        set(value) {
            if let value = value {
                SCPreferencesPathSetValue(self.prefs, path, value as CFDictionary)
            } else {
                SCPreferencesPathRemoveValue(self.prefs, path)
            }
        }
    }
    
    open func createUniqueChild(prefix: Key) -> Key? {
        return SCPreferencesPathCreateUniqueChild(self.prefs, prefix)
    }
    
    open func getLink(path: Key) -> Key? {
        return SCPreferencesPathGetLink(self.prefs, path)
    }
    
    open func setLink(path: Key, link: Key) -> Bool {
        return SCPreferencesPathSetLink(self.prefs, path, link)
    }
    
    open func serviceCreate(interface: NetworkInterface) -> NetworkService? {
        guard let result = SCNetworkServiceCreate(self.prefs, interface.interface) else { return nil }
        return NetworkService(result)
    }
    
    open func serviceCopy(serviceID: CFString) -> NetworkService? {
        guard let result = SCNetworkServiceCopy(self.prefs, serviceID) else { return nil }
        return NetworkService(result)
    }
    
    open func networkSetCreate() -> NetworkSet? {
        guard let result = SCNetworkSetCreate(self.prefs) else { return nil }
        return NetworkSet(result)
    }
    
    open var networkSets: [NetworkSet]? {
        return (SCNetworkSetCopyAll(self.prefs) as? [SCNetworkSet])?.map { NetworkSet($0) }
    }
    
    open var currentNetworkSet: NetworkSet? {
        guard let result = SCNetworkSetCopyCurrent(self.prefs) else { return nil }
        return NetworkSet(result)
    }
    
    open func networkSet(setID: CFString) -> NetworkSet? {
        guard let result = SCNetworkSetCopy(self.prefs, setID) else { return nil }
        return NetworkSet(result)
    }
    
    open var services: [NetworkService]? {
        return (SCNetworkServiceCopyAll(self.prefs) as? [SCNetworkService])?.map { NetworkService($0) }
    }
    
    open func setComputerName(name: CFString?, nameEncoding: CFStringEncoding) -> Bool {
        return SCPreferencesSetComputerName(self.prefs, name, nameEncoding)
    }
    
    open func setComputerName(name: String?, nameEncoding: CFStringEncoding) -> Bool {
        return self.setComputerName(name: name as CFString?, nameEncoding: nameEncoding)
    }
    
    open func setLocalHostName(name: CFString?) -> Bool {
        return SCPreferencesSetLocalHostName(self.prefs, name)
    }
    
    open func setLocalHostName(name: String?) -> Bool {
        return self.setLocalHostName(name: name as CFString?)
    }
    
    // MARK: Bond
    
    open var bondInterfaces: [BondNetworkInterface]? {
        return (SCBondInterfaceCopyAll(self.prefs) as? [SCBondInterface])?.map { BondNetworkInterface($0) }
    }
    
    open var availableBondMemberInterfaces: [NetworkInterface]? {
        return (SCBondInterfaceCopyAvailableMemberInterfaces(self.prefs) as? [SCNetworkInterface])?.map { NetworkInterface($0) }
    }
    
    open func bondCreate() -> BondNetworkInterface? {
        guard let result = SCBondInterfaceCreate(self.prefs) else { return nil }
        return BondNetworkInterface(result)
    }
    
    // MARK: VLAN
    
    open var vlanInterfaces: [VLANNetworkInterface]? {
        return (SCVLANInterfaceCopyAll(self.prefs) as? [SCVLANInterface])?.map { VLANNetworkInterface($0) }
    }
    
    open func vlanCreate(physical: VLANNetworkInterface, tag: CFNumber) -> VLANNetworkInterface? {
        guard let result = SCVLANInterfaceCreate(self.prefs, physical.interface, tag) else { return nil }
        return VLANNetworkInterface(result)
    }
}
