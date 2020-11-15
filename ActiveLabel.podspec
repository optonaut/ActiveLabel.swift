Pod::Spec.new do |s|
	s.name    = 'ActiveLabel'
	s.version = '1.1.5'

	s.author      = { 'Optonaut' => 'hello@optonaut.co' }
	s.homepage    = 'https://github.com/optonaut/ActiveLabel.swift'
	s.license     = { :type => 'MIT', :file => 'LICENSE' }
	s.platform    = :ios, '10.0'
	s.source      = { :git => 'https://github.com/optonaut/ActiveLabel.swift.git', :tag => s.version.to_s }
	s.summary     = 'UILabel drop-in replacement supporting Hashtags (#), Mentions (@), URLs (http://) and custom regex patterns, written in Swift'
	s.description = <<-DESC
		UILabel drop-in replacement supporting Hashtags (#), Mentions (@), URLs (http://) and custom regex patterns, written in Swift

		Features
			* Up-to-date: Swift 5.0 and Xcode 10.2
			* Default support for Hashtags, Mentions, Links
			* Support for custom types via regex
			* Ability to enable highlighting only for the desired types
			* Ability to trim urls
			* Super easy to use and lightweight
			* Works as UILabel drop-in replacement
			* Well tested and documented
	DESC

	s.source_files = 'ActiveLabel/*.swift'
end
