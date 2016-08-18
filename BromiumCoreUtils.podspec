Pod::Spec.new do |s|

  s.name         = "BromiumCoreUtils"
  s.version      = "1.0.0"
  s.summary      = "Core Objective-C/Cocoa utilities by Bromium Inc."
  s.homepage     = "https://github.com/jbmorley/BromiumCoreUtils"
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = { "Jason Barrie Morley" => "jason.morley@inseven.co.uk" }
  s.source       = { :git => "https://github.com/jbmorley/BromiumCoreUtils.git", :tag => "1.0.0" }

  s.source_files = 'BromiumCoreUtils/BRUAsserts.{h,m}', 'BromiumCoreUtils/BRUInternalMaybeDDLog.{h,m}', 'BromiumCoreUtils/BRUBaseDefines.{h,m}', 'BromiumCoreUtils/BRUDispatchUtils.{h,m}'

  s.requires_arc = true

  s.platform = :ios, "9.0", :osx, "10.10"

end
