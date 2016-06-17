# ActiveLabel.swift [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Build Status](https://travis-ci.org/optonaut/ActiveLabel.swift.svg)](https://travis-ci.org/optonaut/ActiveLabel.swift)

UILabel drop-in replacement supporting Hashtags (#), Mentions (@), URLs (http://) and emails (user@mail.com) written in Swift

## Features

* Swift 2+
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
label.handleMailTap { mail in
  print("Success. You just tapped the \(mail) mail")
}
```

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
            label.mailColor = UIColor(red: 200.0/255, green: 50.0/255, blue: 60/255, alpha: 1)
            label.mailSelectedColor = UIColor(red: 200.0/255, green: 50.0/255, blue: 60/255, alpha: 0.75)


            label.handleMentionTap { self.alert("Mention", message: $0) }
            label.handleHashtagTap { self.alert("Hashtag", message: $0) }
            label.handleURLTap { self.alert("URL", message: $0.absoluteString) }
            label.handleMailTap { self.alert("Mail", message: $0) }
        }


```


## API
##### `mailColor: UIColor = .blueColor()`
##### `mailSelectedColor: UIColor?`
##### `mentionColor: UIColor = .blueColor()`
##### `mentionSelectedColor: UIColor?`
##### `hashtagColor: UIColor = .blueColor()`
##### `hashtagSelectedColor: UIColor?`
##### `URLColor: UIColor = .blueColor()`
##### `URLSelectedColor: UIColor?`
##### `lineSpacing: Float?`

##### `handleMailTap: (String) -> ()`

```swift
label.handleMailTap { mailHandle in print("\(mailHandle) tapped") }
```
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

##### `filterHashtag: (String) -> Bool`

```swift
label.filterHashtag { hashtag in validHashtags.contains(hashtag) }
```

##### `filterMention: (String) -> Bool`

```swift
label.filterMention { mention in validMentions.contains(mention) }
```

## Install (iOS 8+)

### Carthage

Add the following to your `Cartfile` and follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

```
github "optonaut/ActiveLabel.swift"
```

### CocoaPods

CocoaPods 0.36 adds supports for Swift and embedded frameworks. To integrate ActiveLabel into your project add the following to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

pod 'ActiveLabel'
```

## Alternatives

Before writing `ActiveLabel` we've tried a lot of the following alternatives but weren't quite satisfied with the quality level or ease of usage, so we decided to contribute our own solution.

* [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) (ObjC) - A drop-in replacement for UILabel that supports attributes, data detectors, links, and more
* [STTweetLabel](https://github.com/SebastienThiebaud/STTweetLabel) (ObjC) - A UILabel with #hashtag @handle and links tappable
* [AMAttributedHighlightLabel](https://github.com/rootd/AMAttributedHighlightLabel) (ObjC) - A UILabel subclass with mention/hashtag/link highlighting
* [KILabel](https://github.com/Krelborn/KILabel) (ObjC) - A simple to use drop in replacement for UILabel for iOS 7 and above that highlights links such as URLs, twitter style usernames and hashtags and makes them touchable
