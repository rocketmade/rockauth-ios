//
//  InstagramProvider.swift
//  Pods
//
//  Created by Daniel Gubler on 10/29/15.
//
//

import UIKit

public class InstagramProvider :SocialProvider, IGViewControllerDelegate {

public static var sharedProvider: SocialProvider?

    public var name: String = "instagram"
    public var secret :String?
    public var token :String?
    public var iconName: String? = "instagramIcon"
    public var userName: String? = nil
    public var email: String? = nil
    public var firstName: String? = nil
    public var lastName: String? = nil
    public var color = UIColor(colorLiteralRed: 117/255.0, green: 111/255.0, blue: 103/255.0, alpha: 1.0)
    var igAppId :String?
    var igRedirectUri :String?

    var successBlock: loginSuccess?
    var failureBlock: loginFailure?
    
    private var webViewController = IGViewController()

    
    public init(instagramAppId :String, registeredRedirectUri :String) {
        igAppId = instagramAppId
        igRedirectUri = registeredRedirectUri
    }
    
    public func login(fromViewController viewController: UIViewController, success: loginSuccess, failure: loginFailure) {
        self.successBlock = success
        self.failureBlock = failure
        webViewController = IGViewController(delegate: self, callbackUrl: self.igRedirectUri)
        if let navController = viewController.navigationController {
            navController.pushViewController(webViewController, animated: true)
        } else {
            viewController.presentViewController(webViewController, animated: true, completion: nil)
        }
        let urlStr = "https://api.instagram.com/oauth/authorize/?client_id=\(igAppId!)&redirect_uri=\(igRedirectUri!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)&response_type=token&scope=basic"
        let authUrl = NSURL(string: urlStr)!
        webViewController.webView.loadRequest(NSURLRequest(URL: authUrl))
    }
    
    public func logout() {
        //Instagram has a different sign in model so we have to delete the cached response from the webview.
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for c in cookies where c.domain == ".instagram.com"{
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(c)
            }
        }
    }
    
    // MARK: helper methods

    // MARK: IGViewControllerDelegate methods
    
    func success(token: String) {
        webViewController.dismissViewControllerAnimated(true, completion: nil)
        NSLog("token:\(token)")
        self.token = token
        
        if let sharedClient = RockauthClient.sharedClient {
            sharedClient.login(self, success: { (user) -> Void in
                if let successBlock = self.successBlock {
                    successBlock(session: user)
                }
                }, failure: { (error) -> Void in
                    if let failureBlock = self.failureBlock {
                        failureBlock(error: error)
                    }
            })
        }
    }
    
    func failure(error: String) {
        webViewController.dismissViewControllerAnimated(true, completion: nil)
        if let failureBlock = self.failureBlock {
            failureBlock(error: RockauthError(title: "Twitter Authentication Error", message: error))
        }
    }
}

// MARK: IGViewController

class IGViewController :UIViewController, UIWebViewDelegate {
    
    let webView = UIWebView()
    var callbackUrl :String?
    var delegate :IGViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    init(delegate :IGViewControllerDelegate, callbackUrl :String?) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.callbackUrl = callbackUrl
        setup()
    }
    
    override func viewDidLoad() {
        applyConstraints()
    }
    
    override func loadView() {
        super.loadView()
        self.view = UIView()
        self.view.backgroundColor = UIColor.whiteColor()
//        webView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(webView)
        applyConstraints()
    }
    
    func setup() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.delegate = self
    }
    
    func applyConstraints() {
        if let _ = self.navigationController {
            view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0))
        } else {
            view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 20))
        }
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
    }
    
    // MARK: webView delegate methods
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.URL!.absoluteString
        if url.startsWith(callbackUrl!) {
            let token = extractToken(url)
            delegate?.success(token)
            return false
        }
        return true
    }
    
    func extractToken(url :String) -> String {
        let b = url.split("=")
        return b[1]
    }
}

// MARK: IGViewControllerDelegate protocol

protocol IGViewControllerDelegate {
    func success(token :String)
    func failure(error :String)
}

// MARK: String extensions

extension String {
    func startsWith(string :String) -> Bool {
        return self.rangeOfString("^\(string)", options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) != nil
    }
    
    func split(char :Character) -> Array<String> {
        return self.characters.split(char).map(String.init)
    }
}