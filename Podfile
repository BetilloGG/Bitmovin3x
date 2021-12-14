platform :ios, '12.0'
use_frameworks!

source 'https://cdn.cocoapods.org'
source 'https://github.com/bitmovin/cocoapod-specs.git'

workspace 'BitmovinPlayerSamples'

def bitmovin_player
  pod 'BitmovinPlayer', '3.10.0'
end

target 'BasicDRMPlayback' do
    project 'BasicDRMPlayback/BasicDRMPlayback.xcodeproj'
    bitmovin_player
end
