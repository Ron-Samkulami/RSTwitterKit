//
//  OAuthParam.swift
//  RSTwitterKit
//
//  Created by Ron on 2023/11/2.
//

import Foundation

@objc
public class TwitterOAuthParam: NSObject {
    /// OAuth1.0
    @objc public var consumerKey: String?
    @objc public var consumerSecret: String?
    /// OAuth2.0
    @objc public var clientId: String?
    
    @objc public var callbackUrl: URL?
    
    @objc
    public static let sharedParam = TwitterOAuthParam()
    private override init() {}
}

