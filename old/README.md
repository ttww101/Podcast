# Podcast iOS Client

[![Build Status](https://travis-ci.org/cuappdev/podcast-ios.svg?branch=master)](https://travis-ci.org/cuappdev/podcast-ios)

Recast is another app from [Cornell AppDev](http://cornellappdev.com), a project team at Cornell University. It is a podcast client that seeks to transform the way you listen to, interact with, and share and discover podcast content.

## Download Recast on the [App Store](https://itunes.apple.com/us/app/recast-find-share-podcasts/id1182878908?ls=1&mt=8)!

![Recast](Marketing/preview.png)

## Development
### Installation
We use [CocoaPods](http://cocoapods.org) for our dependency manager. This should be installed before continuing.

After cloning the project, `cd` into the new directory and install dependencies with
```
pod install
```
Open the Podcast Xcode workspace, `Podcast.xcworkspace`, and enjoy!

### External Collaboration
Our backend url is only available to our team's developers, the app will not connect without it. If you would like to run the app, please clone our team's [backend repository](https://github.com/cuappdev/podcast-backend) and then add your `api-url` in `Keys.plist`.
