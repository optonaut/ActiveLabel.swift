# ActiveLabel.swift [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

UILabel drop-in replacement supporting Hashtags (#), Mentions (@) and URLs (http://) written in Swift

## Features

* Up-to-date: Swift 2 (Beta 6)
* Support for **Hashtags, Mentions and Links**
* Super easy to use and lightweight
* Works as `UILabel` drop-in replacement
* Well tested and documented

## Usage

```swift
import ActiveLabel

let label = ActiveLabel()

label.text = "This is a post with #hashtags and a @userhandle."
label.textColor = .blackColor()
```

## API

##### `mentionEnabled: Bool` (Default: `true`)
##### `hashtagEnabled: Bool` (Default: `true`)
##### `URLEnabled: Bool` (Default: `true`)
##### `mentionColor: UIColor` (Default: `UIColor.blueColor()`)
##### `hashtagColor: UIColor` (Default: `UIColor.blueColor()`)
##### `URLColor: UIColor` (Default: `UIColor.blueColor()`)

##### `handleMentionTap: (String) -> ()`

```swift
label.handleMentionTap { userHandle in print("\(userHandle) tapped") }
```

##### `handleHashtagTap: (String) -> ()`

```swift
label.handleHashtagTap { hashtag in print("\(hashtag) tapped") }
```

##### `handleURLTap: (NSURL) -> ()`

```swift
label.handleURLTap { url in UIApplication.sharedApplication().openURL(url) }
```

## Install

### Carthage

Add the following to your `Cartfile` and follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

```
github "schickling/Device.swift" >= 0.1.0
```
