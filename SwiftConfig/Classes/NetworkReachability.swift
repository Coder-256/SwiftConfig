//
//  NetworkReachability.swift
//  SwiftConfig
//
//  Created by Jacob on 5/25/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

private func reachabilityCallout(target: SCNetworkReachability,
                                 flags: SCNetworkReachabilityFlags,
                                 info: UnsafeMutableRawPointer?) {
    if let info = info {
        ConfigHelper<NetworkReachability, SCNetworkReachabilityContext>.decodeContext(info).callout?(flags)
    }
}

open class NetworkReachability: Hashable, Equatable, CustomStringConvertible {
    private var _target: SCNetworkReachability?
    // swiftlint:disable:next force_unwrapping
    open var target: SCNetworkReachability { return self._target! }
    open var callout: ((SCNetworkReachabilityFlags) -> Void)?

    private func setupCallout() {
        var context = ConfigHelper<NetworkReachability, SCNetworkReachabilityContext>.makeContext(self)
        guard SCNetworkReachabilitySetCallback(self.target,
                                               reachabilityCallout(target:flags:info:),
                                               &context) else { fatalError("SCNetworkReachabilitySetCallback failed") }
    }

    public init(_ target: SCNetworkReachability) {
        self._target = target
        setupCallout()
    }

    public init(address: sockaddr) throws {
        var addrCopy = address
        self._target = try SCNetworkReachabilityCreateWithAddress(nil, &addrCopy)~
        setupCallout()
    }

    // If there's a better way to do this, let me know!
    public init(localAddress: sockaddr?, remoteAddress: sockaddr?) throws {
        if var localCopy = localAddress {
            if var remoteCopy = remoteAddress {
                self._target = try SCNetworkReachabilityCreateWithAddressPair(nil, &localCopy, &remoteCopy)~
            } else {
                self._target = try SCNetworkReachabilityCreateWithAddressPair(nil, &localCopy, nil)~
            }
        } else {
            if var remoteCopy = remoteAddress {
                self._target = try SCNetworkReachabilityCreateWithAddressPair(nil, nil, &remoteCopy)~
            } else {
                self._target = try SCNetworkReachabilityCreateWithAddressPair(nil, nil, nil)~
            }
        }

        setupCallout()
    }

    public init(nodeName: String) throws {
        self._target = try SCNetworkReachabilityCreateWithName(nil, nodeName)~
        setupCallout()
    }

    open func flags() -> SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(self.target,
                                            &flags) else { fatalError("SCNetworkReachabilityGetFlags failed") }
        return flags
    }

    open var hashValue: Int {
        return self.target.hashValue
    }

    open static func == (lhs: NetworkReachability, rhs: NetworkReachability) -> Bool {
        return lhs.target == rhs.target
    }

    open var description: String {
        return CFCopyDescription(self.target) as String? ?? String(describing: self.target)
    }
}
