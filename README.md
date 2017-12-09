# SwiftColorGen
![Swift 4.0](https://img.shields.io/badge/Swift-4.0-green.svg)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

**This repository hosts the core package used by the tool [SwiftColorGen](https://github.com/fernandodelrio/SwiftColorGen)**

A tool that generate code for Swift projects, designed to improve the maintainability of UIColors.

# <a id="motivation"></a> Motivation

Manage colors in iOS projects can be challenging. It would be useful to reuse colors in different places in the storyboard and also access them programmatically. In code, you can group the colors in one place, but it's common to have the same color redefined in many places in the storyboards. When you need to update a color, you need to remember to replace them everywhere and because of that, it becomes hard to maintain.

Since Xcode 9, we are able to define a color asset in the Assets catalog, allowing us to reuse a color inside the storyboards and access them programmatically. Though, this still isn't perfect:
1. To access the colors programmatically, we use a string with the Asset name. If we rename the Asset, we need to remember to replace the strings referring the old asset
2. If we rename an Asset, we also need to manually replace the references to them in the storyboards
3. In an existing project with no color assets defined, we need to group all the colors in the storyboards, manually create the asset colors and replace them everywhere.

# <a id="solution"></a> The solution

**SwiftColorGen** reads all storyboard files to find common colors, it creates them in a **.xcassets** folder (without any duplications) and refer them back in the storyboard. Then, it creates an **UIColor extension** allowing to access the same colors programmatically. It automatically puts a name to the colors found. The name will be the closest webcolor name, measuring the color distance between them. But, the user still can rename the colors and it will keep the storyboards updated.

The rules for naming the colors dinamically:
- The closest web color name (https://en.wikipedia.org/wiki/Web_colors) is considered to name the color
- If the alpha value is less than 255, an "alpha suffix" will be appended to the color name, to avoid name collision
- If two RGB's are close to the same web color, the name still will be used if they have different alphas
- If two RGB's are close to the same web color and they also have the same alpha, the hex of the RGB will be used to avoid name collision

SwiftColorGen is written in Swift and requires Swift to run. The project uses [AEXML](https://github.com/tadija/AEXML) as a dependency to read and write XML and [CommandLine](https://github.com/jatoben/CommandLine) to provide the command line interface.

# <a id="contributing"></a> Contributing
This project still on a initial stage of development. Feel free to contribute by testing it and reporting bugs. If you want to help developing it, checkout the issues section. If you fixed some issue or made some enhancement, open a pull request.

# <a id="license"></a> License
SwiftColorGen is available under the MIT license. See the LICENSE file for more info.
