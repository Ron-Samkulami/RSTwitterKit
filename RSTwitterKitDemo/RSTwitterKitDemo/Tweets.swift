//
//  Tweets.swift
//  RSTwitterKitDemo
//
//  Created by Ron on 15/01/2022.
//

import SwiftUI
import RSTwitterKit

struct Tweets: View {
  @EnvironmentObject var twitterClient: Twift
  
    var body: some View {
      Form {
        Section("Manage Tweets") {
          NavigationLink(destination: PostTweet()) { MethodRow(label: "`postTweet(_ tweet)`") }
        }
      }.navigationTitle("Tweets")
    }
  
  var isEnabled: Bool {
    switch twitterClient.authenticationType {
    case .appOnly(_): return true
    default: return false
    }
  }
}

struct Tweets_Previews: PreviewProvider {
    static var previews: some View {
        Tweets()
    }
}
