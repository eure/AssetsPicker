Pod::Spec.new do |spec|

  spec.name         = "MosaiqueAssetsPicker"
  spec.version      = "1.0.0"
  spec.summary      = "Your customizable asset picker."

  spec.description  = "Your customizable asset picker."

  spec.homepage     = "https://github.com/eure/AssetsPicker"

  spec.license      = "MIT"

  spec.author             = { "Aymen Rebouh" => "aymenmse@gmail.com" }

  spec.source       = { :git => "https://github.com/eure/AssetsPicker.git", :tag => "#{spec.version}" }

  spec.source_files  = ['Sources/AssetsPicker/**/*.{swift,h}']
  spec.public_header_files = 'Sources/AssetsPicker/**/*.h'
  spec.requires_arc = true
  spec.ios.deployment_target = '10.0'
  spec.swift_version = "5.0"
end
