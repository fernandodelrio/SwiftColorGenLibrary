//
//  ColorSpaceManager.swift
//  SwiftColorGen
//
//  Created by Fernando del Rio (fernandomdr@gmail.com) on 02/12/17.
//

import Foundation
import AppKit
import AEXML

open class ColorSpaceManager {
    // Converts the storyboard colors to sRGB
    open static func convertToSRGB(xml: AEXMLElement) {
        guard xml.name == "color" else {
            return
        }

        // Custom
        let cocoaTouchSystemColor = xml.attributes["cocoaTouchSystemColor"] ?? ""
        if !cocoaTouchSystemColor.isEmpty {
            convertCustomColor(xml: xml)
        }

        let customColorSpace = xml.attributes["customColorSpace"] ?? ""
        let colorSpace = xml.attributes["colorSpace"] ?? ""

        // Returns, if already sRGB
        if customColorSpace == "sRGB" {
            return
        }

        // Gray scale color spaces
        if colorSpace == "calibratedWhite" {
            convertCalibratedWhite(xml: xml)
        }
        if colorSpace == "deviceWhite" {
            convertDeviceWhite(xml: xml)
        }
        if customColorSpace == "genericGamma22GrayColorSpace" {
            convertGenericGamma22Gray(xml: xml)
        }

        // RGB color spaces
        if customColorSpace == "displayP3" {
            convertDisplayP3(xml: xml)
        }
        if customColorSpace == "adobeRGB1998" {
            convertAdobeRGB1998(xml: xml)
        }
        if colorSpace == "deviceRGB" {
            convertDeviceRGB(xml: xml)
        }
        if colorSpace == "calibratedRGB" {
            convertCalibratedRGB(xml: xml)
        }

        // CYMK color spaces

        if customColorSpace == "genericCMYKColorSpace" {
            convertGenericCMYK(xml: xml)
        }
        if colorSpace == "deviceCMYK" {
            convertDeviceCMYK(xml: xml)
        }

        // Catalog
        if colorSpace == "catalog" {
            convertCatalog(xml: xml)
        }
    }

    // Gets the correct color data (it can be 0.0 to 1.0, 0 to 255 or hex)
    open static func convertAssetToSRGB(components: [String: String],
                                        colorSpace: String) -> ColorData {
        if colorSpace == "srgb" {
            return parseAssetRGBA(components: components)
        }
        if colorSpace == "extended-srgb" {
            return convertExtendedSRGB(components: components)
        }
        if colorSpace == "extended-linear-srgb" {
            return convertExtendedLinearSRGB(components: components)
        }
        if colorSpace == "display-p3" {
            return convertDisplayP3(components: components)
        }
        if colorSpace == "gray-gamma-22" {
            return convertGrayGamma22(components: components)
        }
        if colorSpace == "extended-gray" {
            return convertExtendedGray(components: components)
        }
        return ColorData()
    }

    // MARK: Gray scale color spaces

    private static func convertGrayGamma22(components: [String: String]) -> ColorData {
        let colorData = ColorData()
        let white = CGFloat(Double(components["white"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(components["alpha"] ?? "") ?? 0.0)
        if #available(OSX 10.12, *) {
            guard let color = NSColor(genericGamma22White: white, alpha: alpha)
                                .usingColorSpace(.sRGB) else {
                return colorData
            }
            var correctedComponents: [String : String] = [:]
            correctedComponents["red"] = String(describing: color.redComponent)
            correctedComponents["green"] = String(describing: color.greenComponent)
            correctedComponents["blue"] = String(describing: color.blueComponent)
            correctedComponents["alpha"] = String(describing: color.alphaComponent)
            return parseAssetRGBA(components: correctedComponents)
        }
        return colorData
    }

    private static func convertExtendedGray(components: [String: String]) -> ColorData {
        let colorData = ColorData()
        let white = CGFloat(Double(components["white"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(components["alpha"] ?? "") ?? 0.0)
        if #available(OSX 10.12, *) {
            guard let color = NSColor(colorSpace: .extendedGenericGamma22Gray, components: [white, alpha], count: 2)
                                .usingColorSpace(.sRGB) else {
                return colorData
            }
            var correctedComponents: [String : String] = [:]
            correctedComponents["red"] = String(describing: color.redComponent)
            correctedComponents["green"] = String(describing: color.greenComponent)
            correctedComponents["blue"] = String(describing: color.blueComponent)
            correctedComponents["alpha"] = String(describing: color.alphaComponent)
            return parseAssetRGBA(components: correctedComponents)
        }
        return colorData
    }

    private static func convertCalibratedWhite(xml: AEXMLElement) {
        let white = CGFloat(Double(xml.attributes["white"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(xml.attributes["alpha"] ?? "") ?? 0.0)
        guard let color = NSColor(calibratedWhite: white, alpha: alpha)
                            .usingColorSpace(.sRGB) else {
            return
        }
        xml.attributes["customColorSpace"] = "sRGB"
        xml.attributes["colorSpace"] = "custom"
        xml.attributes["white"] = nil
        xml.attributes["red"] = "\(color.redComponent)"
        xml.attributes["green"] = "\(color.greenComponent)"
        xml.attributes["blue"] = "\(color.blueComponent)"
        xml.attributes["alpha"] = "\(color.alphaComponent)"
    }

    private static func convertDeviceWhite(xml: AEXMLElement) {
        let white = CGFloat(Double(xml.attributes["white"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(xml.attributes["alpha"] ?? "") ?? 0.0)
        guard let color = NSColor(deviceWhite: white, alpha: alpha)
                            .usingColorSpace(.sRGB) else {
            return
        }
        xml.attributes["customColorSpace"] = "sRGB"
        xml.attributes["colorSpace"] = "custom"
        xml.attributes["white"] = nil
        xml.attributes["red"] = "\(color.redComponent)"
        xml.attributes["green"] = "\(color.greenComponent)"
        xml.attributes["blue"] = "\(color.blueComponent)"
        xml.attributes["alpha"] = "\(color.alphaComponent)"
    }

    private static func convertGenericGamma22Gray(xml: AEXMLElement) {
        let white = CGFloat(Double(xml.attributes["white"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(xml.attributes["alpha"] ?? "") ?? 0.0)
        guard let color = NSColor(genericGamma22White: white, alpha: alpha)
                            .usingColorSpace(.sRGB) else {
            return
        }
        xml.attributes["customColorSpace"] = "sRGB"
        xml.attributes["colorSpace"] = "custom"
        xml.attributes["white"] = nil
        xml.attributes["red"] = "\(color.redComponent)"
        xml.attributes["green"] = "\(color.greenComponent)"
        xml.attributes["blue"] = "\(color.blueComponent)"
        xml.attributes["alpha"] = "\(color.alphaComponent)"
    }

    // MARK: RGB color spaces

    private static func convertExtendedSRGB(components: [String: String]) -> ColorData {
        let colorData = ColorData()
        let red = CGFloat(Double(components["red"] ?? "") ?? 0.0)
        let green = CGFloat(Double(components["green"] ?? "") ?? 0.0)
        let blue = CGFloat(Double(components["blue"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(components["alpha"] ?? "") ?? 0.0)
        if #available(OSX 10.12, *) {
            guard let color = NSColor(colorSpace: .extendedSRGB, components: [red, green, blue, alpha], count: 4)
                                .usingColorSpace(.sRGB) else {
                return colorData
            }
            var correctedComponents: [String : String] = [:]
            correctedComponents["red"] = String(describing: color.redComponent)
            correctedComponents["green"] = String(describing: color.greenComponent)
            correctedComponents["blue"] = String(describing: color.blueComponent)
            correctedComponents["alpha"] = String(describing: color.alphaComponent)
            return parseAssetRGBA(components: correctedComponents)
        }
        return colorData
    }

    private static func convertExtendedLinearSRGB(components: [String: String]) -> ColorData {
        let colorData = ColorData()
        let red = CGFloat(Double(components["red"] ?? "") ?? 0.0)
        let green = CGFloat(Double(components["green"] ?? "") ?? 0.0)
        let blue = CGFloat(Double(components["blue"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(components["alpha"] ?? "") ?? 0.0)
        if #available(OSX 10.12, *) {
            guard let extendedLinearSRGBColorSpace = CGColorSpace(name: CGColorSpace.extendedLinearSRGB) else {
                return colorData
            }
            guard let sRGBColorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
                return colorData
            }
            guard let cgColor = CGColor(colorSpace: extendedLinearSRGBColorSpace,
                                        components: [red, green, blue, alpha]) else {
                return colorData
            }
            guard let correctedCGColor = cgColor.converted(to: sRGBColorSpace,
                                                           intent: .defaultIntent,
                                                           options: nil) else {
                return colorData
            }
            guard let color = NSColor(cgColor: correctedCGColor) else {
                return colorData
            }
            var correctedComponents: [String : String] = [:]
            correctedComponents["red"] = String(describing: color.redComponent)
            correctedComponents["green"] = String(describing: color.greenComponent)
            correctedComponents["blue"] = String(describing: color.blueComponent)
            correctedComponents["alpha"] = String(describing: color.alphaComponent)
            return parseAssetRGBA(components: correctedComponents)
        }
        return colorData
    }

    private static func convertDisplayP3(components: [String: String]) -> ColorData {
        let colorData = ColorData()
        let red = CGFloat(Double(components["red"] ?? "") ?? 0.0)
        let green = CGFloat(Double(components["green"] ?? "") ?? 0.0)
        let blue = CGFloat(Double(components["blue"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(components["alpha"] ?? "") ?? 0.0)
        if #available(OSX 10.12, *) {
            guard let color = NSColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
                                .usingColorSpace(.sRGB) else {
                return colorData
            }
            var correctedComponents: [String : String] = [:]
            correctedComponents["red"] = String(describing: color.redComponent)
            correctedComponents["green"] = String(describing: color.greenComponent)
            correctedComponents["blue"] = String(describing: color.blueComponent)
            correctedComponents["alpha"] = String(describing: color.alphaComponent)
            return parseAssetRGBA(components: correctedComponents)
        }
        return colorData
    }

    private static func convertDisplayP3(xml: AEXMLElement) {
        let red = CGFloat(Double(xml.attributes["red"] ?? "") ?? 0.0)
        let green = CGFloat(Double(xml.attributes["green"] ?? "") ?? 0.0)
        let blue = CGFloat(Double(xml.attributes["blue"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(xml.attributes["alpha"] ?? "") ?? 0.0)
        if #available(OSX 10.12, *) {
            guard let color = NSColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
                                .usingColorSpace(.sRGB) else {
                return
            }
            xml.attributes["customColorSpace"] = "sRGB"
            xml.attributes["colorSpace"] = "custom"
            xml.attributes["red"] = "\(color.redComponent)"
            xml.attributes["green"] = "\(color.greenComponent)"
            xml.attributes["blue"] = "\(color.blueComponent)"
            xml.attributes["alpha"] = "\(color.alphaComponent)"
        }
    }

    private static func convertAdobeRGB1998(xml: AEXMLElement) {
        let red = CGFloat(Double(xml.attributes["red"] ?? "") ?? 0.0)
        let green = CGFloat(Double(xml.attributes["green"] ?? "") ?? 0.0)
        let blue = CGFloat(Double(xml.attributes["blue"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(xml.attributes["alpha"] ?? "") ?? 0.0)
        guard let color = NSColor(colorSpace: .adobeRGB1998, components: [red, green, blue, alpha], count: 4)
                            .usingColorSpace(.sRGB) else {
            return
        }
        xml.attributes["customColorSpace"] = "sRGB"
        xml.attributes["colorSpace"] = "custom"
        xml.attributes["red"] = "\(color.redComponent)"
        xml.attributes["green"] = "\(color.greenComponent)"
        xml.attributes["blue"] = "\(color.blueComponent)"
        xml.attributes["alpha"] = "\(color.alphaComponent)"
    }

    private static func convertDeviceRGB(xml: AEXMLElement) {
        let red = CGFloat(Double(xml.attributes["red"] ?? "") ?? 0.0)
        let green = CGFloat(Double(xml.attributes["green"] ?? "") ?? 0.0)
        let blue = CGFloat(Double(xml.attributes["blue"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(xml.attributes["alpha"] ?? "") ?? 0.0)
        guard let color = NSColor(deviceRed: red, green: green, blue: blue, alpha: alpha)
                            .usingColorSpace(.sRGB) else {
            return
        }
        xml.attributes["customColorSpace"] = "sRGB"
        xml.attributes["colorSpace"] = "custom"
        xml.attributes["red"] = "\(color.redComponent)"
        xml.attributes["green"] = "\(color.greenComponent)"
        xml.attributes["blue"] = "\(color.blueComponent)"
        xml.attributes["alpha"] = "\(color.alphaComponent)"
    }

    private static func convertCalibratedRGB(xml: AEXMLElement) {
        let red = CGFloat(Double(xml.attributes["red"] ?? "") ?? 0.0)
        let green = CGFloat(Double(xml.attributes["green"] ?? "") ?? 0.0)
        let blue = CGFloat(Double(xml.attributes["blue"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(xml.attributes["alpha"] ?? "") ?? 0.0)
        guard let color = NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
                            .usingColorSpace(.sRGB) else {
            return
        }
        xml.attributes["customColorSpace"] = "sRGB"
        xml.attributes["colorSpace"] = "custom"
        xml.attributes["red"] = "\(color.redComponent)"
        xml.attributes["green"] = "\(color.greenComponent)"
        xml.attributes["blue"] = "\(color.blueComponent)"
        xml.attributes["alpha"] = "\(color.alphaComponent)"
    }

    // MARK: CYMK color spaces

    private static func convertGenericCMYK(xml: AEXMLElement) {
        let cyan = CGFloat(Double(xml.attributes["cyan"] ?? "") ?? 0.0)
        let yellow = CGFloat(Double(xml.attributes["yellow"] ?? "") ?? 0.0)
        let magenta = CGFloat(Double(xml.attributes["magenta"] ?? "") ?? 0.0)
        let black = CGFloat(Double(xml.attributes["black"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(xml.attributes["alpha"] ?? "") ?? 0.0)
        guard let color = NSColor(colorSpace: .genericCMYK,
                                  components: [cyan, magenta, yellow, black, alpha], count: 5)
                            .usingColorSpace(.sRGB) else {
            return
        }
        xml.attributes["customColorSpace"] = "sRGB"
        xml.attributes["colorSpace"] = "custom"
        xml.attributes["red"] = "\(color.redComponent)"
        xml.attributes["green"] = "\(color.greenComponent)"
        xml.attributes["blue"] = "\(color.blueComponent)"
        xml.attributes["alpha"] = "\(color.alphaComponent)"
    }

    private static func convertDeviceCMYK(xml: AEXMLElement) {
        let cyan = CGFloat(Double(xml.attributes["cyan"] ?? "") ?? 0.0)
        let yellow = CGFloat(Double(xml.attributes["yellow"] ?? "") ?? 0.0)
        let magenta = CGFloat(Double(xml.attributes["magenta"] ?? "") ?? 0.0)
        let black = CGFloat(Double(xml.attributes["black"] ?? "") ?? 0.0)
        let alpha = CGFloat(Double(xml.attributes["alpha"] ?? "") ?? 0.0)
        guard let color = NSColor(deviceCyan: cyan,
                                  magenta: magenta,
                                  yellow: yellow,
                                  black: black,
                                  alpha: alpha).usingColorSpace(.sRGB) else {
            return
        }
        xml.attributes["customColorSpace"] = "sRGB"
        xml.attributes["colorSpace"] = "custom"
        xml.attributes["red"] = "\(color.redComponent)"
        xml.attributes["green"] = "\(color.greenComponent)"
        xml.attributes["blue"] = "\(color.blueComponent)"
        xml.attributes["alpha"] = "\(color.alphaComponent)"
    }

    // MARK: Catalog
    private static func convertCatalog(xml: AEXMLElement) {
        let colorList = NSColorList.Name(xml.attributes["catalog"] ?? "")
        let colorName = NSColor.Name(xml.attributes["name"] ?? "")
        guard let catalogColor = NSColor(catalogName: colorList, colorName: colorName),
              let color = catalogColor.usingColorSpace(.sRGB) else {
            return
        }
        xml.attributes["customColorSpace"] = "sRGB"
        xml.attributes["colorSpace"] = "custom"
        xml.attributes["red"] = "\(color.redComponent)"
        xml.attributes["green"] = "\(color.greenComponent)"
        xml.attributes["blue"] = "\(color.blueComponent)"
        xml.attributes["alpha"] = "\(color.alphaComponent)"
    }

    // MARK: Custom color

    private static func convertCustomColor(xml: AEXMLElement) {
        // Didn't found a better way to do that, so
        //   I'm just returning the value for the colors,
        //   when the color on storyboard has the key
        //   cocoaTouchSystemColor
        let cocoaTouchSystemColor = xml.attributes["cocoaTouchSystemColor"] ?? ""
        if cocoaTouchSystemColor == "darkTextColor" {
            xml.attributes["colorSpace"] = "custom"
            xml.attributes["customColorSpace"] = "genericGamma22GrayColorSpace"
            xml.attributes["white"] = "0.0"
            xml.attributes["alpha"] = "1"
        }
        if cocoaTouchSystemColor == "groupTableViewBackgroundColor" {
            xml.attributes["colorSpace"] = "custom"
            xml.attributes["customColorSpace"] = "sRGB"
            xml.attributes["red"] = "0.93725490199999995"
            xml.attributes["green"] = "0.93725490199999995"
            xml.attributes["blue"] = "0.95686274510000002"
            xml.attributes["alpha"] = "1"
        }
        if cocoaTouchSystemColor == "lightTextColor" {
            xml.attributes["colorSpace"] = "custom"
            xml.attributes["customColorSpace"] = "genericGamma22GrayColorSpace"
            xml.attributes["white"] = "1"
            xml.attributes["alpha"] = "0.59999999999999998"
        }
        if cocoaTouchSystemColor == "scrollViewTexturedBackgroundColor" {
            xml.attributes["colorSpace"] = "custom"
            xml.attributes["customColorSpace"] = "sRGB"
            xml.attributes["red"] = "0.43529411759999997"
            xml.attributes["green"] = "0.4431372549"
            xml.attributes["blue"] = "0.47450980390000003"
            xml.attributes["alpha"] = "1"
        }
        if cocoaTouchSystemColor == "tableCellGroupedBackgroundColor" {
            xml.attributes["colorSpace"] = "custom"
            xml.attributes["customColorSpace"] = "genericGamma22GrayColorSpace"
            xml.attributes["white"] = "1"
            xml.attributes["alpha"] = "1"
        }
        if cocoaTouchSystemColor == "viewFlipsideBackgroundColor" {
            xml.attributes["colorSpace"] = "custom"
            xml.attributes["customColorSpace"] = "sRGB"
            xml.attributes["red"] = "0.1215686275"
            xml.attributes["green"] = "0.12941176469999999"
            xml.attributes["blue"] = "0.14117647059999999"
            xml.attributes["alpha"] = "1"
        }
        xml.attributes["cocoaTouchSystemColor"] = nil
    }

    // MARK: Utils

    private static func parseAssetRGBA(components: [String: String]) -> ColorData {
        let colorData = ColorData()
        guard let red = components["red"],
            let green = components["green"],
            let blue = components["blue"],
            let alpha = components["alpha"] else {
                return colorData
        }
        if red.contains(".") { // 0.0 to 1.0
            colorData.red = Double(red) ?? 0.0
            colorData.green = Double(green) ?? 0.0
            colorData.blue = Double(blue) ?? 0.0
        } else if red.contains("x") { // 0x00 to 0xFF
            colorData.red = Double(Int(red.suffix(2), radix: 16) ?? 0)/255
            colorData.green = Double(Int(green.suffix(2), radix: 16) ?? 0)/255
            colorData.blue = Double(Int(blue.suffix(2), radix: 16) ?? 0)/255
        } else { // 0 to 255
            colorData.red = (Double(red) ?? 0.0)/255
            colorData.green = (Double(green) ?? 0.0)/255
            colorData.blue = (Double(blue) ?? 0.0)/255
        }
        colorData.alpha = Double(alpha) ?? 0.0
        return colorData
    }
}
