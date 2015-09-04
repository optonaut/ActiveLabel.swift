# ActiveLabel.swift [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Build Status](https://travis-ci.org/optonaut/ActiveLabel.swift.svg)](https://travis-ci.org/optonaut/ActiveLabel.swift)

UILabel drop-in replacement supporting Hashtags (#), Mentions (@) and URLs (http://) written in Swift

## Features

* Up-to-date: Swift 2 (Beta 6)
* Support for **Hashtags, Mentions and Links**
* Super easy to use and lightweight
* Works as `UILabel` drop-in replacement
* Well tested and documented

![](ActiveLabelDemo/demo.gif)

## Usage

```swift
import ActiveLabel

let label = ActiveLabel()

label.numberOfLines = 0
label.text = "This is a post with #hashtags and a @userhandle."
label.textColor = .blackColor()
label.handleHashtagTap { hashtag in
  print("Success. You just tapped the \(hashtag) hashtag")
}
```

## API

##### `mentionEnabled: Bool = true`
##### `hashtagEnabled: Bool = true`
##### `URLEnabled: Bool = true`
##### `mentionColor: UIColor = .blueColor()`
##### `mentionSelectedColor: UIColor = .blueColor()`
##### `hashtagColor: UIColor = .blueColor()`
##### `hashtagSelectedColor: UIColor = .blueColor()`
##### `URLColor: UIColor = .blueColor()`
##### `URLSelectedColor: UIColor = .blueColor()`

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

## Install (iOS 8+) 

### Carthage

Add the following to your `Cartfile` and follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

```
github "schickling/Device.swift" >= 0.1.0
```
