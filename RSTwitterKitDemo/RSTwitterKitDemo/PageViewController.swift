//
//  PageViewController.swift
//  RSTwitterKitDemo
//
//  Created by Ron on 2023/11/1.
//

import UIKit
import SwiftUI
import RSTwitterKit

/// 遵循UIViewControllerRepresentable协议
struct SwiftUICallSwift: UIViewControllerRepresentable {
    
    var color : UIColor?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = SwiftViewController()
        vc.color = color
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
}

/// SwiftUI（此处的作用是为了设置导航，如果直接从上个页面push到TestViewController，导航返回按钮点击将无效）
struct SwiftUIViewController: View {
    @Environment(\.presentationMode) var presentationMode
    @State var color : UIColor?
    
    var body: some View{
        VStack{
            SwiftUICallSwift(color: color)
        }.navigationBarTitle("SwiftVC->SwiftUI", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
//                Image("nav_back_black")
                Text("Back")
            }))
    }
}

// UIViewController
class SwiftViewController: UIViewController {
    
    var color : UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = color ?? .orange
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 20, width: 200, height: 50)
        button.setTitle("弹出推文编辑界面", for: .normal)
        button.addTarget(self, action: #selector(showTweetVC), for: .touchUpInside)
        self.view.addSubview(button)
        
    }
    
    @objc func showTweetVC() {
        let image = UIImage(named: "photo.jpeg")
        
        TwitterSDK.sharedInstance().showTweetComposer(withText: "推文内容\nxxxx", image: image, from: self) { result in
            print("发推结果：\(result)")
        }
    }

}
