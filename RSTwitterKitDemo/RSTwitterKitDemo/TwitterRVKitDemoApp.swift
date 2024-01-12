//
//  RSTwitterKitDemoApp.swift
//  RSTwitterKitDemo
//
//  Created by Ron on 2023/10/31.
//

import SwiftUI
import RSTwitterKit

extension Twift {
    var hasUserAuth: Bool {
        switch authenticationType {
        case .appOnly(_): return false
        case .userAccessTokens(_, _): return true
        case .oauth2UserAuth(_, _): return true
        }
    }
}

@main
struct RSTwitterKitDemoApp: App {

    @State var bearerToken = ""
    @State var isPush = false
    
    var body: some Scene {
        WindowGroup {
                NavigationView {
                    Form {
                        Section(
                            header: Text("OAuth1.0")
                        ) {
                            AsyncButton {
                                TwitterSDK.sharedInstance().start(withConsumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET, callbackUri: URL(string: TWITTER_CALLBACK_URL)!)
                            } label: {
                                Text("startWithConsumerKey")
                            }
                            
                            AsyncButton {
                                TwitterSDK.sharedInstance().loginOAuth1 { sesssion, error in
                                    guard (sesssion != nil) else {
                                        print("登录失败");
                                        return
                                    }
                                    print(sesssion?.authToken ?? "");
                                }
                            } label: {
                                Text("loginOAuth1")
                            }
                            
                        }
                        
                        Section(
                            header: Text("OAuth2.0")
                        ) {
                            AsyncButton {
                                TwitterSDK.sharedInstance().start(withClientID: CLIENT_ID, callbackUri: URL(string: TWITTER_CALLBACK_URL)!)
                            } label: {
                                Text("startWithClientID")
                            }
                            
                            AsyncButton {
                                TwitterSDK.sharedInstance().loginOAuth2 { (accessToken, error) in
                                    guard !accessToken.isEmpty else {
                                        print("登录失败");
                                        return
                                    }
//                                    print(accessToken);
                                    isPush = true
                                }
                                
                            } label: {
                                Text("loginOAuth2")
                            }
                            
                            AsyncButton {
                                TwitterSDK.sharedInstance().tweetText("我又发了一条推文", image: nil) { (result) in
                                    print("发推完成\(result)")
                                }
                            } label: {
                                Text("Tweet")
                            }
                            
                            NavigationLink(isActive: $isPush) {
                                SwiftUIViewController(color: .white)
                            }label: {
                                Text("发推界面")
                            }
                        }
                        
//                        Section(
//                            header: Text("OAuth 2.0 User Authentication"),
//                            footer: Text("Use this authentication method for most cases. This test app enables all user scopes by default.")
//                        ) {
//                            AsyncButton {
//                                let user = try? await Twift.Authentication().authenticateUser(clientId: CLIENT_ID, redirectUri: URL(string: TWITTER_CALLBACK_URL)!,scope: Set(OAuth2Scope.allCases))
//                                if let user = user {
//                                    container.client = Twift(oauth2User: user) { token in
//                                        onTokenRefresh(token)
//                                    }
//                                }
//                            } label: {
//                                Text("Sign In With Twitter")
//                            }
//                        }
                        Section() {
                            AsyncButton {
                                TwitterSDK.sharedInstance().logout();
                            } label: {
                                Text("Logout")
                            }
                        }
                        
                    }
                    .navigationTitle("Choose Auth Type")
                }
        }
    }

}
