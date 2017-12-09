//
//  Asset.swift
//  SwiftColorGen
//
//  Created by Fernando del Rio (fernandomdr@gmail.com) on 24/11/17.
//

import Foundation

public enum AssetType {
    case original // Generated from storyboard
    case customRenamed // User renamed a color in the Assets folder
    case customAdded // User added a color in the Assets folder
    case customUnmodified // Asset didn't changed since last run
}

// Data structure for the Asset in the Assets folder
open class Asset {
    open var originalName: String?
    open var currentName: String?
    open var path: String?
    open var type: AssetType?
    open var color: ColorData?
}
