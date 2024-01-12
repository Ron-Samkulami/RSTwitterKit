//
//  TwitterComposerViewController.swift
//  RSTwitterKit
//
//  Created by Ron on 2023/11/1.
//

import UIKit

@objc
public class TwitterComposerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    public var text: String = ""
    public var image: UIImage? = nil
    public var completion: ((Int) -> Void)? = { _ in }
    
    @objc
    public convenience init(text: String, image: UIImage? , completion: @escaping (Int) -> Void = { _ in }) {
        self.init()
        self.text = text
        self.image = image
        self.completion = completion
    }
    
    let cancelButton = UIButton()
    let postButton = UIButton()
    let line = UIView()
    let imageView = UIImageView()
    let textView = UITextView()
    let imagePicker = UIImagePickerController()
    
    let buttonWidth = 80.0
    let buttonHeight = 40.0
    let contentMargin = 14.0
    let lineWidth = 1.0
    let cornerRadius = 6.0
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        setupButtons()
        setupLine()
        setupTextView()
        setupImageView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.setNeedsLayout()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        cancelButton.frame = CGRect(x: contentMargin/2, y: contentMargin,
                                    width: buttonWidth, height: buttonHeight)
        postButton.frame = CGRect(x: self.view.frame.width - contentMargin/2 - buttonWidth,
                                  y: contentMargin,
                                  width: buttonWidth,
                                  height: buttonHeight)
        line.frame = CGRect(x: 0,
                            y: CGRectGetMaxY(cancelButton.frame) + contentMargin/2,
                            width: self.view.frame.width,
                            height: lineWidth)
        textView.frame = CGRect(x: contentMargin,
                                y: CGRectGetMaxY(line.frame) + contentMargin,
                                width: self.view.frame.width - contentMargin * 2,
                                height: textView.contentSize.height)
        imageView.frame = CGRect(x: contentMargin,
                                 y: CGRectGetMaxY(textView.frame) + contentMargin,
                                 width: self.view.frame.width - contentMargin * 2,
                                 height: self.view.frame.width - contentMargin * 2)
    }
    
    //MARK: - UI
    func setupButtons() {
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.textAlignment = .left
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        self.view.addSubview(cancelButton)
        
        //TODO: - 中间的X Logo，图片可以直接使用SDKbundle中的，就不必另打bundle了
        
        postButton.setTitle("Post", for: .normal)
        postButton.titleLabel?.textAlignment = .right
        postButton.setTitleColor(.systemBlue, for: .normal)
        postButton.addTarget(self, action: #selector(postButtonAction), for: .touchUpInside)
        self.view.addSubview(postButton)
    }
    
    func setupLine() {
        line.layer.borderWidth = lineWidth/2
        line.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        self.view.addSubview(line)
    }
    
    func setupImageView() {
        guard self.image != nil else {
            return
        }
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = lineWidth
        imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        imageView.image = self.image
        setupImagePicker()
        self.view.addSubview(imageView)
    }
    
    func setupTextView() {
        textView.delegate = self
        textView.backgroundColor = .white
        textView.font = .systemFont(ofSize: 16)
        textView.layer.cornerRadius = cornerRadius
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = lineWidth
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
//        textView.placeholder = "Enter text"
        textView.text = self.text
        self.view.addSubview(textView)
    }
    
    func setupImagePicker() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    //MARK: - Action
    /// 点击取消按钮
    @objc func cancelButtonAction() {
        let alert = UIAlertController(title: "Delete and quit？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            if self.completion != nil {
                // 取消返回错误码 -1
                self.completion!(-1)
            }
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    /// 点击发送按钮
    @objc func postButtonAction() {
        // 异步方法封装到Task中
        Task {
            let result = await TwitterSwiftHandler.sharedHandler.tweet(text: textView.text, image: imageView.image)
            
            if completion != nil {
                completion!(result.rawValue)
            }
            dismiss(animated: true)
        }
    }

    /// 点击图片
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - UITextViewDelegate
    
    public func textViewDidChange(_ textView: UITextView) {
        // 编辑文本时，动态调整编辑框高度
        self.view.setNeedsLayout()
    }
    
    //MARK: - UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
            self.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
}
