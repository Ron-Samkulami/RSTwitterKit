//
//  TwitterSwiftHandler.swift
//  RSTwitterKit
//
//  Created by Ron on 2023/10/31.
//

import Foundation


class ClientContainer: ObservableObject {
    @Published var client1: Twift?
    @Published var client2: Twift?
    @KeychainItem(account: "twitterOAuth2User") var twitterOAuth2User
}


@objc
public class TwitterSwiftHandler: NSObject {
    // 全局变量，保存
    var container = ClientContainer()
    
    @objc
    public static let sharedHandler = TwitterSwiftHandler()
    private override init() {}
    
    //MARK: - OAuth1.0
    
    /// OAuth1.0 登录
    /// - Parameters:
    ///   - consumerKey: consumerKey
    ///   - consumerSecret: consumerSecret
    ///   - callbackURL: callbackURL
    ///   - completion: completion
    @objc
    public func requestUserCredentials(completion:@escaping ((_ authToken: String?, _ authTokenSecret: String?, _ userID: String?, _ error: Error?) -> Void) ) {
        guard let consumerKey = TwitterOAuthParam.sharedParam.consumerKey,
           let consumerSecret = TwitterOAuthParam.sharedParam.consumerSecret,
           let callbackURL = TwitterOAuthParam.sharedParam.callbackUrl else {
            print("[RSTwitterKit] OAuth1.0 parameter incompleted! consumerKey = \(String(describing: TwitterOAuthParam.sharedParam.consumerKey)), consumerSecret = \(String(describing: TwitterOAuthParam.sharedParam.consumerSecret)), callbackUrl = \(String(describing: TwitterOAuthParam.sharedParam.callbackUrl))")
            let error = NSError(domain: "OAuth1.0 parameter incompleted!", code: -1)
            completion(nil,nil,nil,error)
            return
        }
        let clientCredentials = OAuthCredentials(key: consumerKey, secret: consumerSecret)
        Twift.Authentication().requestUserCredentials(clientCredentials: clientCredentials, callbackURL: callbackURL) { (userCredentials: OAuthCredentials?, error: Error?) in
            if let error = error {
                completion(nil,nil,nil,error)
                return
            }
            if let userCredentials = userCredentials {
                // 保存授权
                self.container.client1 = Twift(.userAccessTokens(clientCredentials: clientCredentials, userCredentials: userCredentials))
                // 回调完成
                completion(userCredentials.key, userCredentials.secret, userCredentials.userId, error)
            }
        }
    }
    
    
    /// 上传图片，获取图片ID
    /// - Parameter image: 图片
    /// - Returns: 上传后的图片ID
    func upload(image: UIImage? = nil) async -> String? {
        // 图片必须有效
        guard image != nil else {
            return nil
        }
        
        // 检查登录状态
        if !isClient1Valid {
            //TODO: 暂时先通过TwitterSDK间接调用
            do {
                try await TwitterSDK.sharedInstance().loginOAuth1()
            } catch {
                print("[RSTwitterKit] \(error)")
            }
        }
        
        guard isClient1Valid else {
            print("[RSTwitterKit] OAuth1.0 state error!")
            return nil
        }
        
        // 默认使用jpeg格式
        if let imageData = image?.jpegData(compressionQuality: 0.8) {
            print("[RSTwitterKit] Uplod jpeg image")
            return await upload(imageData: imageData, imageType: .jpeg)
            
        } else if let imageData = image?.pngData() {
            print("[RSTwitterKit] Uplod png image")
            return await upload(imageData: imageData, imageType: .png)
        }
        print("[RSTwitterKit] Unknown image type")
        return nil
    }
    
    enum ImageType {
        case jpeg
        case png
        @available(iOS 17.0, *) case heic
    }
    
    /// 上传图片
    /// - Parameters:
    ///   - imageData: 图片数据
    ///   - imageType: 图片类型
    /// - Returns: 图片ID
    func upload(imageData: Data, imageType: ImageType) async -> String? {
        var mimeType = ""
        switch imageType {
        case .png:
            mimeType = "image/png"
        default:
            mimeType = "image/jpeg"
        }
        
        do {
            let response = try await container.client1!.upload(mediaData: imageData, mimeType: mimeType, category: .tweetImage)
            let mediaIdString = response.mediaIdString
            return mediaIdString
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    //MARK: - OAuth2.0
    /// OAuth2.0 登录
    @objc
    public func authenticateUser() async throws -> String? {
        guard let clientId = TwitterOAuthParam.sharedParam.clientId,
              let callbackUrl = TwitterOAuthParam.sharedParam.callbackUrl else {
            print("[RSTwitterKit] OAuth2.0 parameter incompleted! clientId = \(String(describing: TwitterOAuthParam.sharedParam.clientId)), callbackUrl = \(String(describing: TwitterOAuthParam.sharedParam.callbackUrl))")
            return nil
        }
        let user = try? await Twift.Authentication().authenticateUser(clientId: clientId, redirectUri: callbackUrl, scope: Set(OAuth2Scope.allCases))
        if let user = user {
            container.client2 = Twift(oauth2User: user, onTokenRefresh: onOAuth2TokenRefresh)
            // 首次登录完成，保存Token到本地
            onOAuth2TokenRefresh(user)
            
            return user.accessToken
        }
        
        return nil
    }
    
    /// OAuth2.0 Token过期时会自动刷新，这里监听Token更新并保存到本地keychain
    func onOAuth2TokenRefresh(_ token: OAuth2User) {
        print("onOAuth2TokenRefresh: \(token)")
        guard let encoded = try? JSONEncoder().encode(token) else { return }
        container.twitterOAuth2User = String(data: encoded, encoding: .utf8)
    }
    
    /// 恢复本地缓存的OAuth2.0账户
    @objc
    public func restoreCachedClient2() {
        if let keychainItem = container.twitterOAuth2User?.data(using: .utf8) {
            if let decoded = try? JSONDecoder().decode(OAuth2User.self, from: keychainItem) {
                if !decoded.accessToken.isEmpty {
                    container.client2 = Twift(oauth2User: decoded, onTokenRefresh: onOAuth2TokenRefresh)
                }
                
            }
        }
    }
    
    /// 发推结果，注意这里的枚举rawValue要和对外接口的一致
    @objc
    public enum TweetResult: Int {
        case failed = 0
        case success = 1
        case canceled
    }
    
    
    /// 发送推文
    /// - Parameters:
    ///   - text: 推文内容
    ///   - image: 推文附图
    /// - Returns: 发推结果
    @objc
    public func tweet(text: String? = nil, image: UIImage? = nil ) async -> TweetResult {
        
        do {
            if !isClient2Valid {
                _ = try await authenticateUser()
            }
            
            var tweet = MutableTweet(text: text)
            if image != nil {
                let mediaIdString = await upload(image: image)
                guard mediaIdString != nil else {
                    // 有图片时必须上传完成才能继续发推，否则直接阻断
                    return .failed
                }
                let media = MutableMedia(mediaIds: [mediaIdString!])
                tweet = MutableTweet(text: text, media: media)
            }
            
            
            let response = try await container.client2!.postTweet(tweet)
            
            let tweetId = response.data.id
            return tweetId.isEmpty ? .failed : .success
            
        } catch {
            print(error)
        }
        return .failed
    }

    
    //MARK: - Other
    /// 登出
    @objc public func logout() {
        container.client1 = nil
        container.client2 = nil
        container.twitterOAuth2User = nil
    }
    
    @objc public var isClient1Valid: Bool {
        return container.client1 != nil
    }
    
    @objc public var isClient2Valid: Bool {
        return container.client2 != nil
    }
    
}
