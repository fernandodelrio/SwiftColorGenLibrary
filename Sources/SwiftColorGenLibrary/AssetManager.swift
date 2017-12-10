//
//  AssetManager.swift
//  SwiftColorGen
//
//  Created by Fernando del Rio (fernandomdr@gmail.com) on 24/11/17.
//

import Foundation

open class AssetManager {
    // Gets asset data from the Assets folder
    open static func getAssetColors(assetsFolder: String) -> [Asset] {
        let assets = getAssets(assetsFolder: assetsFolder)
        var assetColors: [Asset] = []
        assets.forEach { colorset in
            let newAsset = Asset()
            newAsset.color = getAssetColor(colorsetFolder: colorset)
            newAsset.path = colorset
            // It's a new custom color, if there's no swiftcg.json
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: "\(colorset)/swiftcg.json")) else {
                newAsset.originalName = getAssetName(path: colorset)
                newAsset.currentName = newAsset.originalName
                newAsset.type = .customAdded
                assetColors.append(newAsset)
                return
            }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let json = jsonObject as? [String: Any] else {
                return
            }
            let name = json["name"] as? String ?? ""
            let custom = json["custom"] as? Bool ?? false
            // If the name on the folder is different from the swiftcg.json
            //   it's a renamed color
            if name != getAssetName(path: colorset) {
                newAsset.originalName = name
                newAsset.currentName = getAssetName(path: colorset)
                newAsset.type = .customRenamed
                assetColors.append(newAsset)
                return
            }
            // If custom is marked with false, it's a original generated color
            //   (color generated from storyboard). In this case, we can change
            //   the name
            if !custom {
                newAsset.originalName = name
                newAsset.currentName = name
                newAsset.type = .original
                assetColors.append(newAsset)
                return
            }
            // No condition matched, the color wasn't modified
            newAsset.originalName = name
            newAsset.currentName = name
            newAsset.type = .customUnmodified
            assetColors.append(newAsset)
        }
        return assetColors
    }
    
    // Deletes all colorsets, preparing for a new code generation
    open static func deleteColorsets(assets: [Asset]) {
        let original = assets.filter { $0.type == .original }
        original.forEach { try? FileManager.default.removeItem(atPath: $0.path ?? "") }
    }
    
    // Updates swiftcg.json name and set custom to true
    open static func updateCustomJson(assets: [Asset]) {
        let customAssets = assets.filter {
            $0.type == .customRenamed ||
            $0.type == .customAdded
        }
        customAssets.forEach { customAsset in
            let colorPath = customAsset.path ?? ""
            let metaData = "{\"name\": \"\(customAsset.currentName ?? "")\", \"custom\": true}"
            let metaDataPath = "\(colorPath)/swiftcg.json"
            try? metaData.write(to: URL(fileURLWithPath: metaDataPath), atomically: false, encoding: .utf8)
        }
    }
    
    // Write all colors to the .xcassets folder
    open static func writeColorAssets(path: String, colors: Set<ColorData>) {
        let generatorData = ColorManager.getColorsForGenerator(colors: colors)
        generatorData.forEach { data in
            let colorPath = "\(path)/\(data.assetName).colorset"
            let contentsPath = "\(colorPath)/Contents.json"
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: colorPath), withIntermediateDirectories: false, attributes: nil)
            let contentsData = "{\"info\":{\"version\":1,\"author\":\"xcode\"},\"colors\":[{\"idiom\":\"universal\",\"color\":{\"color-space\":\"srgb\",\"components\":{\"red\":\"\(data.color.red)\",\"alpha\":\"\(data.color.alpha)\",\"blue\":\"\(data.color.blue)\",\"green\":\"\(data.color.green)\"}}}]}"
            try? contentsData.write(to: URL(fileURLWithPath: contentsPath), atomically: false, encoding: .utf8)
            let metaDataPath = "\(colorPath)/swiftcg.json"
            let metaData = "{\"name\": \"\(data.assetName)\", \"custom\": false}"
            try? metaData.write(to: URL(fileURLWithPath: metaDataPath), atomically: false, encoding: .utf8)
        }
    }
    
    // Gets the asset color using the Content.json values
    private static func getAssetColor(colorsetFolder: String) -> ColorData {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "\(colorsetFolder)/Contents.json")) else {
            return ColorData()
        }
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let json = jsonObject as? [String: Any] else {
            return ColorData()
        }
        guard let colors = (json["colors"] as? [[String: Any]])?.first else {
            return ColorData()
        }
        guard let color = colors["color"] as? [String: Any] else {
            return ColorData()
        }
        guard let components = color["components"] as? [String: String] else {
            return ColorData()
        }
        guard let colorSpace = color["color-space"] as? String else {
            return ColorData()
        }
        let colorData = ColorSpaceManager.convertAssetToSRGB(components: components, colorSpace: colorSpace)
        return colorData
    }
    
    // Iterate over the base folder to get the storyboard files
    private static func getAssets(assetsFolder: String) -> [String] {
        var assets: [String] = []
        let enumerator = FileManager.default.enumerator(atPath: assetsFolder)
        while let path = enumerator?.nextObject() as? String {
            if PathManager.isValidColorset(path: path) {
                assets.append("\(assetsFolder)/\(path)")
            }
        }
        return assets
    }
    
    // Gets the asset name, using the colorset folder name
    private static func getAssetName(path: String) -> String {
        let path = path.split(separator: "/")
        let end = path.last ?? ""
        return end.replacingOccurrences(of: ".colorset", with: "")
    }
}
