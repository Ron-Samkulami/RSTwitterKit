//
//  UploadMedia.swift
//  RSTwitterKitDemo
//
//  Created by Ron on 20/01/2022.
//

import SwiftUI
import RSTwitterKit

struct UploadMedia: View {
  @EnvironmentObject var twitterClient: Twift
  @State var image: UIImage?
  @State var isPickingPhoto = false
  var body: some View {
    Form {
        
      Button(action: { isPickingPhoto = true }) {
        Text("Choose photo")
      }
      
      AsyncButton {
        do {
//            if let imageData = image?.pngData() {
            if let imageData = image?.jpegData(compressionQuality: 0.8) {
              
            // upload media via OAuth 1.0a authentication
              let response = try await twitterClient.upload(mediaData: imageData, mimeType: "image/jpeg", category: .tweetImage)
                print(response.mediaId)
          }
        } catch {
          print(error.localizedDescription)
        }
      } label: {
        Text("Upload image")
      }.disabled(image == nil)

        
    }.sheet(isPresented: $isPickingPhoto) {
      ImagePicker(chosenImage: $image)
    }.navigationTitle("Upload Image")
  }
}

struct UploadMedia_Previews: PreviewProvider {
  static var previews: some View {
    UploadMedia()
  }
}
