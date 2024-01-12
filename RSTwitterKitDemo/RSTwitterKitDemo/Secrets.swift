import Foundation

//MARK: - auth2参数
// 登录只需要用到这两个，不需要用到api_key(consumer_key)
let CLIENT_ID="ZllKeVNoNzBaVWNhcm14OEkxeWI6MTpjaQ"
let TWITTER_CALLBACK_URL="twift-test://"

//MARK: - auoth1.0参数
/// 这两个参数在上传图片的接口要填到consumerCredentials中，固定参数
let TWITTER_CONSUMER_KEY = "GDBZx1pnVLnslDPrm5hTjyyj0"
let TWITTER_CONSUMER_SECRET = "5IcWgfxef4O31ghKZHdQ0GiobNL9Q6KJq2Mz7hyMbTGvcSRZYQ"

/// 这两个参数在上传图片的接口要填到userCredentials中，不过现在SDK中会自动从后台获取
let ACCESS_TOKEN = "1479743337066233856-NlS1jXMYaTUO1Xn1ZR6LNgwJFj0xGT"
let ACCESS_TOKEN_SECRET = "ToiquCSu92SAj0d5I206LLId1VTGONMRtrOQFTt17S67D"
