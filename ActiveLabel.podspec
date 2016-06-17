Pod::Spec.new do |s|
	s.name    = 'ActiveLabel'
	s.version = '0.5.2'

	s.author      = { 'Optonaut' => 'hello@optonaut.co' }
	s.homepage    = 'https://github.com/AlbertoMDieguez/ActiveLabel.swift'
	s.license     = { :type => 'MIT', :file => 'LICENSE' }
	s.platform    = :ios, '8.0'
	s.source      = { :git => 'https://github.com/AlbertoMDieguez/ActiveLabel.swift.git', :tag => s.version.to_s }
	s.summary     = 'UILabel drop-in replacement supporting Hashtags (#), Mentions (@), URLs (http://)  and Mails (user@mail.com) written in Swift'
	s.description = <<-DESC
		UILabel drop-in replacement supporting Hashtags (#), Mentions (@) and URLs (http://) written in Swift

		Features
			* Up-to-date: Swift 2 (Xcode 7 GM)
			* Support for Hashtags, Mentions, Links and Mails
			* Super easy to use and lightweight
			* Works as UILabel drop-in replacement
			* Well tested and documented
	DESC

	s.source_files = 'ActiveLabel/*.swift'
end
