//
//  ContentView.swift
//  RSTwitterKitDemo
//
//  Created by Ron on 2023/10/25.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            Form {
                Section("Examples") {
                  NavigationLink(destination: Tweets()) { Label("Tweets", systemImage: "bubble.left") }
                  NavigationLink(destination: UploadMedia()) { Label("Upload Image", systemImage: "photo") }
                }/*.disabled(!twitterClient.hasUserAuth)*/
            }
        }
    }
}

#Preview {
    ContentView()
}
