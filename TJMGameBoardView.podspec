Pod::Spec.new do |s|
  s.name         = "TJMGameBoardView"
  s.version      = "1.0.0"
  s.summary      = "A simple game board view written in Objective-C."
  s.description  = "A simple implementation of a grid that UIViews can be placed on."
  s.homepage     = "https://github.com/Cubd/Game-Board-View"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Cubd" => "email@address.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/Cubd/Game-Board-View.git", :tag => "1.0.0" }
  s.source_files  = "Source/**/*.{h,m}"
  s.exclude_files = "Test Project"
  s.requires_arc = true
  s.dependency "TJMTwoDimensionalArray", "~> 1.0"
end
