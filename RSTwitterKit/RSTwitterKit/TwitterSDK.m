//
//  TwitterSDK.m
//  RSTwitterKit
//
//  Created by Ron on 2023/10/31.
//

#import "TwitterSDK.h"
#import <RSTwitterKit/RSTwitterKit-Swift.h>


@interface TWSession ()
@property (nonatomic, readwrite) NSString *authToken;
@property (nonatomic, readwrite) NSString *authTokenSecret;
@property (nonatomic, readwrite) NSString *userID;
@end

@implementation TWSession

- (instancetype)initWithAuthToken:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret userID:(NSString *)userID {
    if ([self init]) {
        self.authToken = authToken;
        self.authTokenSecret = authTokenSecret;
        self.userID = userID;
    }
    return self;
}
@end



//MARK: - TwitterSDK

@interface TwitterSDK ()
/// 是否正在登录
@property (nonatomic, assign) BOOL isLogining;
@end

@implementation TwitterSDK

+ (instancetype)sharedInstance {
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

//MARK: - OAuth1.0
/// 初始化，保存参数到单例中
- (void)startWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret callbackUri:(NSURL *)callbackUrl {
    TwitterOAuthParam.sharedParam.consumerKey = consumerKey;
    TwitterOAuthParam.sharedParam.consumerSecret = consumerSecret;
    TwitterOAuthParam.sharedParam.callbackUrl = callbackUrl;
}

/// OAuth1.0登录
- (void)loginOAuth1WithCompletion:(void(^)(TWSession *_Nullable session, NSError *_Nullable error))completion {
    if (_isLogining) {
        NSLog(@"[RSTwitterKit] Ignoring duplicated login attempt.");
        return;
    }
    self.isLogining = YES;
    
    [[TwitterSwiftHandler sharedHandler] requestUserCredentialsWithCompletion:^(NSString * _Nullable authToken, NSString * _Nullable authTokenSecret, NSString * _Nullable userID, NSError * _Nullable error) {
        if (!error && authToken && authTokenSecret) {
            NSLog(@"[RSTwitterKit] Login via OAuth1.0 success!");
            TWSession *session = [[TWSession alloc] initWithAuthToken:authToken authTokenSecret:authTokenSecret userID:userID];
            if (completion) {
                completion(session, error);
            }
        } else {
            NSLog(@"[RSTwitterKit] Login via OAuth1.0 failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
        
        self.isLogining = NO;
    }];
}


//MARK: - OAuth2.0
/// 初始化，保存参数到单例中
- (void)startWithClientID:(NSString *)clientId callbackUri:(NSURL *)callbackUrl {
    TwitterOAuthParam.sharedParam.clientId = clientId;
    TwitterOAuthParam.sharedParam.callbackUrl = callbackUrl;
    
    //FIXME: 这里恢复本地缓存的数据时，可能会导致授权态丢失
//    [[TwitterSwiftHandler sharedHandler] restoreCachedClient2];
}

/// OAuth2.0登录
- (void)loginOAuth2WithCompletion:(void (^)(NSString *, NSError * _Nullable))completion {
    if (_isLogining) {
        NSLog(@"[RSTwitterKit] Ignoring duplicated login attempt.");
        return;
    }
    self.isLogining = YES;
    
    [[TwitterSwiftHandler sharedHandler] authenticateUserWithCompletionHandler:^(NSString * _Nullable accessToken, NSError * _Nullable error) {
        if (!error && accessToken) {
            NSLog(@"[RSTwitterKit] Login via OAuth2.0 success!");
            if (completion) {
                completion(accessToken, error);
            }
        } else {
            //授权出错
            NSLog(@"[RSTwitterKit] Login via OAuth2.0 failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
        
        self.isLogining = NO;
    }];
}

//MARK: - Tweet
/// 发送推文
- (void)tweetText:(NSString *)text image:(UIImage *)image completion:(void (^)(NSInteger))completion {
    // 先检查v2登录态，否则无法发推
    if (![TwitterSwiftHandler sharedHandler].isClient2Valid) {
        [self loginOAuth2WithCompletion:^(NSString * _Nonnull accessToken, NSError * _Nullable error) {
            if (accessToken && !error) {
                [self checkImageUploaderAndTweetText:text image:image completion:completion];
            } else {
                NSLog(@"[RSTwitterKit] Tweet failed due to OAuth2.0 failed!");
                if (completion) {
                    completion(TweetTweetPostResultFailed);
                }
            }
        }];
    } else {
        [self checkImageUploaderAndTweetText:text image:image completion:completion];
    }
}

- (void)checkImageUploaderAndTweetText:(NSString *)text image:(UIImage *)image completion:(void (^)(NSInteger))completion {
    // 有图片时，先检查v1登录态，否则无法上传
    if (image != nil && ![TwitterSwiftHandler sharedHandler].isClient1Valid) {
        [self loginOAuth1WithCompletion:^(TWSession * _Nullable session, NSError * _Nullable error) {
            if (session.authToken != nil) {
                [[TwitterSwiftHandler sharedHandler] tweetWithText:text image:image completionHandler:completion];
            } else {
                NSLog(@"[RSTwitterKit] Tweet failed due to OAuth1.0 failed!");
                if (completion) {
                    completion(TweetTweetPostResultFailed);
                }
            }
        }];
    } else {
        [[TwitterSwiftHandler sharedHandler] tweetWithText:text image:image completionHandler:completion];
    }
}

/// 展示推文编辑界面
- (void)showTweetComposerWithText:(NSString *)text image:(UIImage *)image fromViewController:(nonnull UIViewController *)viewController completion:(void (^ _Nullable)(NSInteger))completion {
    NSAssert(viewController != nil, @"[RSTwitterKit] Show Tweet Composer From Empty View Controller!!");
    
    // 先检查V2授权是否完成
    if (![TwitterSwiftHandler sharedHandler].isClient2Valid) {
        [self loginOAuth2WithCompletion:^(NSString * _Nonnull accessToken, NSError * _Nullable error) {
            if (accessToken && !error) {
                [self presentTweetComposerWithText:text image:image fromViewController:viewController completion:completion];
            } else {
                NSLog(@"[RSTwitterKit] Show tweet composer failed due to OAuth2.0 failed!");
                if (completion) {
                    completion(TweetTweetPostResultFailed);
                }
            }
        }];
    } else {
        [self presentTweetComposerWithText:text image:image fromViewController:viewController completion:completion];
    }
    
}

- (void)presentTweetComposerWithText:(NSString *)text image:(UIImage *)image fromViewController:(UIViewController *)viewController completion:(void (^)(NSInteger))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        TwitterComposerViewController *vc = [[TwitterComposerViewController alloc] initWithText:text image:image completion:completion];
        if (viewController) {
            [viewController presentViewController:vc animated:YES completion:nil];
        }
    });
    
}

//MARK: - Other

- (void)logout {
    [[TwitterSwiftHandler sharedHandler] logout];
}

- (NSString *)version {
    return @"0.1";
}

@end
