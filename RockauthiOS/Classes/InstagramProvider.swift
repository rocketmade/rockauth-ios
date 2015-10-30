//
//  InstagramProvider.swift
//  Pods
//
//  Created by Daniel Gubler on 10/29/15.
//
//

import UIKit

public class InstagramProvider :SocialProvider, IGViewControllerDelegate {

public static var sharedProvider: SocialProvider! = InstagramProvider()

    public var name: String = "instagram"
    public var secret :String?
    public var token :String?
    var igAppId :String?
    var igRedirectUri :String?
    
    private var webViewController = IGViewController()
    
    public init() {
    }
    
    public func initialize(instagramAppId :String, registeredRedirectUri :String) {
        igAppId = instagramAppId
        igRedirectUri = registeredRedirectUri
    }
    
    public func login(success success: () -> Void, failure: (error: ErrorType) -> Void) {
        presentWebView()
        let urlStr = "https://api.instagram.com/oauth/authorize/?client_id=\(igAppId!)&redirect_uri=\(igRedirectUri!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)&response_type=token&scope=basic"
        let authUrl = NSURL(string: urlStr)!
        webViewController.webView.loadRequest(NSURLRequest(URL: authUrl))
    }
    
    public func logout() {
        // TODO
    }
    
    // MARK: helper methods
    
    func presentWebView() {
        webViewController = IGViewController(delegate: self, callbackUrl: self.igRedirectUri)
        let viewController :UIViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        viewController.presentViewController(webViewController, animated: true, completion: nil)
    }
    
    // MARK: IGViewControllerDelegate methods
    
    func success(token: String) {
        webViewController.dismissViewControllerAnimated(true, completion: nil)
        NSLog("token:\(token)")
        
        if let sharedClient = RockauthClient.sharedClient {
            sharedClient.login(self, success: { (user) -> Void in
                NSLog("Rockauth login success!")
                }, failure: { (error) -> Void in
                NSLog("Rockauth login failure!")
            })
        }
    }
    
    func failure(error: String) {
        webViewController.dismissViewControllerAnimated(true, completion: nil)
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
        self.view.backgroundColor = UIColor.blueColor()
        webView.backgroundColor = UIColor.redColor()
        self.view.addSubview(webView)
        applyConstraints()
    }
    
    func setup() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.delegate = self
    }
    
    func applyConstraints() {
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0))
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