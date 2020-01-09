Pod::Spec.new do |spec|

  spec.name         = "MosaiqueAssetsPicker"
  spec.version      = "1.0.0"
  spec.summary      = "Your customizable asset picker."

  spec.description  = "Your customizable asset picker."

  spec.homepage     = "https://github.com/eure/AssetsPicker"

  spec.license      = "MIT"

  spec.authors             = [
    { "Antoine Marandon" => "antoine@marandon.fr" },
    { "Aymen Rebouh" => "aymenmse@gmail.com" },
    { "John Estropia" => "rommel.estropia@gmail.com>" },
    { "Muukii" => "muukii.app@gmail.com" }
  ]

  spec.source       = { :git => "https://github.com/eure/AssetsPicker.git", :tag => "#{spec.version}" }

  spec.source_files  = ['Sources/MosaiqueAssetsPicker/**/*.{swift,h}']
  spec.requires_arc = true
  spec.ios.deployment_target = '10.0'
  spec.swift_version = "5.0"
end
