# Nuke Toucan Plugin

<p align="left">
<a href="https://cocoapods.org"><img src="https://img.shields.io/cocoapods/v/Nuke-Toucan-Plugin.svg"></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
</p>

[Toucan](https://github.com/gavinbunney/Toucan) plugin for [Nuke](https://github.com/kean/Nuke) that provides a simple API for processing images. It supports resizing, cropping, rounded rect masking and more.


## Usage

The plugin adds two methods in an extension of `Nuke.Request` which let you easily use first-class Toucan API to process your image:

```swift
var request = Nuke.Request(url: url)
request.process(key: "Avatar") {
    return $0.resize(CGSize(width: 500, height: 500), fitMode: .crop)
             .maskWithEllipse()
}
```

And a non-mutating method:
```swift
let request = Nuke.Request(url: url).processed(key: "Avatar") { 
    return $0.resize(CGSize(width: 500, height: 500), fitMode: .crop)
             .maskWithEllipse()
}
```

A key which you provide in the request is used to compare image processors. Equivalent image processors should have the same key. Sometimes a simple string like "Avatar" will do.

Naturally you can add your own extensions to `Nuke.Request` to describe common operations.

## Installation

### [CocoaPods](http://cocoapods.org)

To install the plugin add a dependency to your Podfile:

```ruby
# source 'https://github.com/CocoaPods/Specs.git'
# use_frameworks!

pod 'Nuke-Toucan-Plugin'
pod 'Toucan'
```

### [Carthage](https://github.com/Carthage/Carthage)

To install the plugin add a dependency to your Cartfile:

```
github "kean/Nuke-Toucan-Plugin"
```

## Requirements

- iOS 9 / tvOS 9
- Xcode 8
- Swift 3

## Dependencies

- [Nuke 5](https://github.com/kean/Nuke)
- [Toucan 0.6](https://github.com/gavinbunney/Toucan)

## License

Nuke is available under the MIT license. See the LICENSE file for more info.
