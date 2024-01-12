//
//  TwitterSDK.h
//  RSTwitterKit
//
//  Created by Ron on 2023/10/31.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWSession : NSObject

@property (nonatomic, readonly, copy) NSString *authToken;
@property (nonatomic, readonly, copy) NSString *authTokenSecret;
@property (nonatomic, readonly, copy) NSString *userID;

- (instancetype)initWithAuthToken:(NSString * __nullable)authToken authTokenSecret:(NSString * __nullable)authTokenSecret userID:(NSString * __nullable)userID;
@end

typedef NS_ENUM(NSInteger, TweetPostResult) {
    TweetTweetPostResultCanceled = -1,  // 分享取消
    TweetTweetPostResultFailed,         // 分享失败
    TweetTweetPostResultSuccess,        // 分享成功
};

@interface TwitterSDK : NSObject

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, copy, readonly) NSString *version;

/// 登出
- (void)logout;


//MARK: - OAuth1.0

/// 初始化，使用OAuth1.0参数
/// - Parameters:
///   - consumerKey: consumerKey
///   - consumerSecret: consumerSecret
///   - callbackUrl: callbackUrl
- (void)startWithConsumerKey:(NSString *)consumerKey 
              consumerSecret:(NSString *)consumerSecret
                 callbackUri:(NSURL *)callbackUrl ;

/// OAuth1.0授权登录
/// - Parameter completion: 登录回调，返回用户授权信息
- (void)loginOAuth1WithCompletion:(void(^)(TWSession *_Nullable session, NSError *_Nullable error))completion;


//MARK: - OAuth2.0

/// 初始化，使用OAuth2.0参数
/// - Parameters:
///   - clientId: clientId
///   - callbackUrl: callbackUrl
- (void)startWithClientID:(NSString *)clientId 
              callbackUri:( NSURL *)callbackUrl;

/// OAuth2.0授权登录
/// - Parameter completion: 登录回调，返回用户授权信息
- (void)loginOAuth2WithCompletion:(void (^)(NSString *accessToken, NSError *__nullable error))completion;


//MARK: - Tweet

/// 直接发送推文
/// - Parameters:
///   - text: 文本内容
///   - image: 图片
///   - completion: 发推操作完成回调， result 1 成功，0失败
- (void)tweetText:(NSString *)text 
            image:(UIImage *__nullable)image
       completion:(void(^ __nullable)(NSInteger result))completion;

/// 显示推文编辑页面
/// - Parameters:
///   - text: 文本内容
///   - image: 图片
///   - viewController: 来源控制器
///   - completion: 发推操作完成回调， result 1 成功，0失败， -1取消
- (void)showTweetComposerWithText:(NSString * __nullable)text 
                            image:(UIImage * __nullable)image
               fromViewController:(UIViewController *)viewController
                       completion:(void(^ __nullable)(NSInteger result))completion;

@end
NS_ASSUME_NONNULL_END
