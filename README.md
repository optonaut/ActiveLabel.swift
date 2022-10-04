# ActiveLabel.swift [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Build Status](https://travis-ci.org/optonaut/ActiveLabel.swift.svg)](https://travis-ci.org/optonaut/ActiveLabel.swift)

UILabel drop-in replacement supporting Hashtags (#), Mentions (@), URLs (http://), Emails and custom regex patterns, written in Swift

## Features

* Swift 5.0 (1.1.0+) and 4.2 (1.0.1)
* Default support for **Hashtags, Mentions, Links, Emails**
* Support for **custom types** via regex
* Ability to enable highlighting only for the desired types
* Ability to trim urls
* Super easy to use and lightweight
* Works as `UILabel` drop-in replacement
* Well tested and documented

![](ActiveLabelDemo/demo.gif)

## Install (iOS 10+)

### Carthage

Add the following to your `Cartfile` and follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

```sh
github "optonaut/ActiveLabel.swift"
```

### CocoaPods

CocoaPods 0.36 adds supports for Swift and embedded frameworks. To integrate ActiveLabel into your project add the following to your `Podfile`:

```ruby
platform :ios, '10.0'
use_frameworks!

pod 'ActiveLabel'
```

## Usage

```swift
import ActiveLabel

let label = ActiveLabel()
label.numberOfLines = 0
label.enabledTypes = [.mention, .hashtag, .url, .email]
label.text = "This is a post with #hashtags and a @userhandle."
label.textColor = .black
label.handleHashtagTap { hashtag in
    print("Success. You just tapped the \(hashtag) hashtag")
}
```

## Custom types

```swift
let customType = ActiveType.custom(pattern: "\\swith\\b") //Regex that looks for "with"
label.enabledTypes = [.mention, .hashtag, .url, .email, customType]
label.text = "This is a post with #hashtags and a @userhandle."
label.customColor[customType] = UIColor.purple
label.customSelectedColor[customType] = UIColor.green
label.handleCustomTap(for: customType) { element in
    print("Custom type tapped: \(element)")
}
```

## Enable/disable highlighting

By default, an ActiveLabel instance has the following configuration

```swift
label.enabledTypes = [.mention, .hashtag, .url, .email]
```

But feel free to enable/disable to fit your requirements

## Batched customization

When using ActiveLabel, it is recommended to use the `customize(block:)` method to customize it. The reason is that ActiveLabel is reacting to each property that you set. So if you set 3 properties, the textContainer is refreshed 3 times.

When using `customize(block:)`, you can group all the customizations on the label, that way ActiveLabel is only going to refresh the textContainer once.

Example:

```swift
label.customize { label in
    label.text = "This is a post with #multiple #hashtags and a @userhandle."
    label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
    label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
    label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
    label.URLColor = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
    label.handleMentionTap { self.alert("Mention", message: $0) }
    label.handleHashtagTap { self.alert("Hashtag", message: $0) }
    label.handleURLTap { self.alert("URL", message: $0.absoluteString) }
}
```

## Trim long urls

You have the possiblity to set the maximum lenght a url can have;

```swift
label.urlMaximumLength = 30
```

From now on, a url that's bigger than that, will be trimmed.

`https://afancyurl.com/whatever` -> `https://afancyurl.com/wh...`

## API

##### `mentionColor: UIColor = .blueColor()`
##### `mentionSelectedColor: UIColor?`
##### `hashtagColor: UIColor = .blueColor()`
##### `hashtagSelectedColor: UIColor?`
##### `URLColor: UIColor = .blueColor()`
##### `URLSelectedColor: UIColor?`
##### `customColor: [ActiveType : UIColor]`
##### `customSelectedColor: [ActiveType : UIColor]`
##### `lineSpacing: Float?`

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
label.handleURLTap { url in UIApplication.shared.openURL(url) }
```

##### `handleEmailTap: (String) -> ()`

```swift
label.handleEmailTap { email in print("\(email) tapped") }
```

##### `handleCustomTap(for type: ActiveType, handler: (String) -> ())`

```swift
label.handleCustomTap(for: customType) { element in print("\(element) tapped") }
```

##### `filterHashtag: (String) -> Bool`

```swift
label.filterHashtag { hashtag in validHashtags.contains(hashtag) }
```

##### `filterMention: (String) -> Bool`

```swift
label.filterMention { mention in validMentions.contains(mention) }
```

## Alternatives

Before writing `ActiveLabel` we've tried a lot of the following alternatives but weren't quite satisfied with the quality level or ease of usage, so we decided to contribute our own solution.

* [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) (ObjC) - A drop-in replacement for UILabel that supports attributes, data detectors, links, and more
* [STTweetLabel](https://github.com/SebastienThiebaud/STTweetLabel) (ObjC) - A UILabel with #hashtag @handle and links tappable
* [AMAttributedHighlightLabel](https://github.com/rootd/AMAttributedHighlightLabel) (ObjC) - A UILabel subclass with mention/hashtag/link highlighting
* [KILabel](https://github.com/Krelborn/KILabel) (ObjC) - A simple to use drop in replacement for UILabel for iOS 7 and above that highlights links such as URLs, twitter style usernames and hashtags and makes them touchable
