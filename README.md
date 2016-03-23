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

Currently disabled

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

### Google Integration

1. Add the following to your podfile:
  ```ruby
  pod 'Google/SignIn'
  ```

2. Run `pod install`

3. In your AppDelegate's didFinishLaunchingWithOptions add:
  ```
  // Initialize Google sign-in
  var configureError: NSError?
  GGLContext.sharedInstance().configureWithError(&configureError)
  assert(configureError == nil, "Error configuring Google services: \(configureError)")
  ```

4. In the viewController that will be responsible for interacting with Rockauth add the following protocols to your class definition:
  ```
  class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, ConnectWithGoogleDelegate {
  ```
5. In the viewController that will be responsible for interacting with Rockauth add the following to `ViewDidLoad`:
  ```
  GIDSignIn.sharedInstance().delegate = self
  GIDSignIn.sharedInstance().uiDelegate = self

  (GoogleProvider.sharedProvider as! GoogleProvider).delegate = self
  ```
6. Add the following method that will get called when the Google button in the Rockauth UI is clicked:

  ```
  func googleButtonClicked() {
      self.dismissViewControllerAnimated(true, completion: { () -> Void in
          GIDSignIn.sharedInstance().signIn()
      })
  }
  ```
7. Add the `didSignInForUser` delegate method:

  ```
  func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
  withError error: NSError!) {
      if (error == nil) {
          let idToken = user.authentication.idToken
          let gp = GoogleProvider.sharedProvider as! GoogleProvider
          gp.token = idToken
          gp.connect(fromViewController: self, success: { (user) -> Void in
              print(user)
              // User is successfully signed in
              <#code#>
              }, failure: { (error) -> Void in
                  print(error)
          })
      } else {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
              let alertController = UIAlertController(title: "Error Signing In", message: error.localizedDescription, preferredStyle: .Alert)
              let okButton = UIAlertAction(title: "OK", style: .Default, handler:nil)
              alertController.addAction(okButton)
              self.presentViewController(alertController, animated: true, completion: nil)
          })
      }
  }
  ```
8. After creating your app in the Google developer console you must download and add `GoogleService-Info.plist` to your project. If you want the correct plist to be used for the current build configuration eg. Debug, Staging, Release, you can add the following run script to your Build Phases:
  ```
  rm ${SRCROOT}/${PRODUCT_NAME}/GoogleService-Info.plist
  /usr/libexec/PlistBuddy -c "Merge ${SRCROOT}/${PRODUCT_NAME}/${CONFIGURATION}-GoogleService-Info.plist" ${SRCROOT}/${PRODUCT_NAME}/GoogleService-Info.plist
  ```
  Just make sure it is run before 'Copy Bundle Resources'

  You will also need to name each plist like this: `Debug-GoogleService-Info.plist` or `Release-GoogleService-Info.plist`
## Author

Rocketmade, info@rocketmade.com

## License

RockauthIOS is available under the MIT license. See the LICENSE file for more info.
