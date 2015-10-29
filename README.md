# RockauthIOS

[![CI Status](http://img.shields.io/travis/Brayden Morris/RockauthIOS.svg?style=flat)](https://travis-ci.org/Brayden Morris/RockauthIOS)
[![Version](https://img.shields.io/cocoapods/v/RockauthIOS.svg?style=flat)](http://cocoapods.org/pods/RockauthIOS)
[![License](https://img.shields.io/cocoapods/l/RockauthIOS.svg?style=flat)](http://cocoapods.org/pods/RockauthIOS)
[![Platform](https://img.shields.io/cocoapods/p/RockauthIOS.svg?style=flat)](http://cocoapods.org/pods/RockauthIOS)

## Requirements

## Installation

RockauthIOS is available through [CocoaPods](http://cocoapods.org).

1. Add the following line to your Podfile:
  ```ruby
  pod 'RockauthiOS', :git => 'https://github.com/rocketmade/rockauth-ios', :branch => 'dev'
  ```
  
2. Run `pod install`


## Usage

### Basic Rockauth Setup

1. In order for API requests to work, add the following to your AppDelegate (The second part should go in `didFinishLaunchingWithOptions`):

  ```
  import RockauthiOS
  ...
  RockauthClient.sharedClient = RockauthClient(baseURL: <#apiBaseURL: String#>, clientID: <#apiClientID: String#>, clientSecret: <#apiClientSecret: String#>)
  ```
  
2. If your app was not created with Liftoff, the app's Info.plist must contain the following:
  ```
	<key>Configuration</key>
	<string>${CONFIGURATION}</string>
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
  ```
  Or like this:
  
  ![alt tag](/docs/screenshot-plist.png)
  
### Email Registration

### Email Login

### Facebook Integration

### Twitter Integration

1. Add the following to your Podfile:
  ```ruby
  pod 'Fabric'
  pod 'TwitterKit'
  pod 'TwitterCore'
  ```
  
2. Run `pod install`

3. Add the following to your project (possibly in your AppDelegate, specifically in `didFinishLaunchingWithOptions`):
  ```
  import TwitterKit
  ...
  Twitter.sharedInstance().startWithConsumerKey(<#twitterKey: String#>, consumerSecret: <#twitterSecret: String#>)
  ```
  
4. Where you want to invoke 
  ```
  import RockauthiOS
  import TwitterKit
  ...
  func logInWithTwitter() {
      Twitter.sharedInstance().logInWithCompletion { session, error in
          if (session != nil) {
              print("signed in as \(session!.userName)");
              let tp = TwitterProvider(token: session!.authToken, secret: session!.authTokenSecret)
              tp.login(success: { () -> Void in
                  <#code#>
                  }, failure: { (error) -> Void in
                      print(error)
              })
          } else {
              print("error: \(error!.localizedDescription)");
          }
      }
  }
  ```

## Author

Rocketmade, info@rocketmade.com

## License

RockauthIOS is available under the MIT license. See the LICENSE file for more info.
