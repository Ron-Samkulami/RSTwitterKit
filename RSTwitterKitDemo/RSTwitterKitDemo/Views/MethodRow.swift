//
//  MethodRow.swift
//  RSTwitterKitDemo
//
//  Created by Ron on 15/01/2022.
//

import SwiftUI

struct MethodRow: View {
  var label: String
  
  var attributedLabel: AttributedString {
    try! AttributedString(markdown: label)
  }
  
  var body: some View {
    HStack {
      Text(attributedLabel)
      Spacer()
    }.lineLimit(1)
  }
}

struct MethodRow_Previews: PreviewProvider {
    static var previews: some View {
      MethodRow(label: "`getMe()`")
    }
}
