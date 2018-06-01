//
//  ConfigError.swift
//  SwiftConfig
//
//  Created by Jacob on 5/29/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

import Foundation
import SystemConfiguration

public enum CastError: Error {
    case failed
}

postfix operator ~
postfix operator %
infix operator %

/// Guard, else throw error from SystemConfiguration
internal postfix func ~ (_ bool: Bool) throws {
    guard bool else { throw SCCopyLastError() }
}

/// Guard let, else throw error from SystemConfiguration
internal postfix func ~ <T>(_ optional: T?) throws -> T {
    guard let result = optional else { throw SCCopyLastError() }
    return result
}

/// Guard let as?, else throw error from SystemConfiguration or CastError.failed if the cast fails
internal postfix func % <T>(_ optional: AnyObject?) throws -> T {
    guard let result = try optional~ as? T else { throw CastError.failed }
    return result
}

/// Guard let, else throw CastError.failed
internal postfix func % <T>(_ optional: T?) throws -> T {
    guard let result = optional else { throw CastError.failed }
    return result
}
