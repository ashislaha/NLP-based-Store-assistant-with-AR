//
//  ChatViewController.swift
//  NBA Bot
//
//  Created by Pallav Trivedi on 07/02/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//

import ApiAI
import JSQMessagesViewController
import UIKit
import Speech

protocol ChatDelegate: class {
    func navigate(to: ProductDepartment)
}

struct Message {
    static let title = "title"
    static let imageUrl = "imageUrl"
    static let type = "type"
    static let subtitle = "subtitle"
}

class OutgoingAvatar:NSObject, JSQMessageAvatarImageDataSource {
    func avatarImage() -> UIImage! {
        return #imageLiteral(resourceName: "Walmart")
    }
    func avatarHighlightedImage() -> UIImage! {
        return #imageLiteral(resourceName: "Walmart")
    }
    func avatarPlaceholderImage() -> UIImage! {
        return #imageLiteral(resourceName: "Walmart")
    }
}

class IncomingAvatar:NSObject, JSQMessageAvatarImageDataSource {
    func avatarImage() -> UIImage! {
        return #imageLiteral(resourceName: "user_avatar")
    }
    func avatarHighlightedImage() -> UIImage! {
        return #imageLiteral(resourceName: "user_avatar")
    }
    func avatarPlaceholderImage() -> UIImage! {
        return #imageLiteral(resourceName: "user_avatar")
    }
}


class ChatViewController: JSQMessagesViewController {
    
    public var isUserInsideStore: Bool = false // this flag is caputured to restrict few queries to the users
    private let senderIdentifier = "walmart chat bot"
    private let displayName = "Wal-E"
    private let userId = "userId"
    private let userName = "user_name"
    private let initialStatement = "Say something, I'm listening!"
    private var finalIndex: Int = 0
    private var dialogflowMessages: [[String: Any]] = []
    
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    weak var delegate: ChatDelegate?
    private var micButton: UIButton!
    private var tapped = false {
        didSet {
            tapped ? micButton?.setTitle("Stop", for: .normal): micButton?.setTitle("Speech", for: .normal)
            tapped ? SpeechManager.shared.startRecording() : SpeechManager.shared.stopRecording()
        }
    }
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = senderIdentifier
        self.senderDisplayName = displayName
        
        SpeechManager.shared.delegate = self
        addMicButton()
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            self?.populateWithWelcomeMessage()
        })
    }
    
    func addMicButton() {
        let height = self.inputToolbar.contentView.leftBarButtonContainerView.frame.size.height
        micButton = UIButton(type: .custom)
        micButton?.setTitle("Speech", for: .normal)
        micButton?.frame = CGRect(x: 0, y: 0, width: 70, height: height)
        micButton.setTitleColor(.red, for: .normal)
        
        inputToolbar.contentView.leftBarButtonItemWidth = 70
        inputToolbar.contentView.leftBarButtonContainerView.addSubview(micButton)
        inputToolbar.contentView.leftBarButtonItem.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(gesture:)))
        micButton?.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped(gesture: UITapGestureRecognizer) {
        tapped = !tapped
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        return message.senderId == senderId ? OutgoingAvatar(): IncomingAvatar()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell else { return UICollectionViewCell() }
        let message = messages[indexPath.item]
        cell.textView?.textColor = message.senderId == senderId ? UIColor.white: UIColor.black
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        addMessage(withId: userId, name: userName, text: text!)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        performQuery(senderId: userId, name: userName, text: text!)
        tapped = false
        inputToolbar.contentView.textView.text = ""
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        performQuery(senderId: userId, name: userName, text: "Multimedia")
    }
}

// MARK: Dialogflow handling

extension ChatViewController {
    
    func populateWithWelcomeMessage() {
        addMessage(withId: senderId, name: senderDisplayName, text: "Hi I am Walmart-Bot: Wal-E.")
        finishReceivingMessage()
        addMessage(withId: senderId, name: senderDisplayName, text: "I am here to help you.")
        finishReceivingMessage()
    }
    
    func performQuery(senderId:String,name:String,text:String) {
        guard !text.isEmpty else { return }
        let request = ApiAI.shared().textRequest()
        request?.query = text
        
        request?.setMappedCompletionBlockSuccess({ [weak self] (request, response) in
            
            guard let response = response as? AIResponse, let strongSelf = self, let action = response.result.action else { return }
            switch action {
            case "input.searchproduct": strongSelf.handlProductSearch(response: response)
            case "input.navigation": strongSelf.handleNavigation(response: response)
            default: strongSelf.defaultHandling(response: response)
            }
            
            }, failure: { (request, error) in
                print(error?.localizedDescription)
        })
        ApiAI.shared().enqueue(request)
    }
    
    private func handlProductSearch(response: AIResponse) {
        if let messages = response.result.fulfillment.messages as? [[String: Any]], !messages.isEmpty {
            if let dict = messages.first, let speech = dict["speech"] as? String {
                addMessage(withId: senderId, name: senderDisplayName, text: speech)
            } else {
                dialogflowMessages = messages
                finalIndex = messages.count
                productsDetailsWithImages(index: 0)
            }
        }
    }
    
    private func productsDetailsWithImages(index: Int) {
        if index == finalIndex {
            finalIndex = 0
            dialogflowMessages = []
        } else {
            let productDetails = dialogflowMessages[index][Message.title] as? String ?? ""
            let imageUrl = dialogflowMessages[index][Message.imageUrl] as? String ?? ""
            addMessage(withId: senderId, name: senderDisplayName, text: productDetails)
            addMedia(imageUrl: imageUrl, callBack: { [weak self] in
                self?.productsDetailsWithImages(index: index+1)
            })
        }
    }
    
    private func handleNavigation(response: AIResponse) {
        guard let textResponse = response.result.fulfillment.speech else { return }
        if let dest = StoreModel.shared.productToNodeInt[ProductDepartment(rawValue: textResponse)!] {
            SpeechManager.shared.speak(text: "Navigating to " + textResponse)
            finishReceivingMessage()
            delegate?.navigate(to: ProductDepartment(rawValue: textResponse)!)
            navigationController?.popViewController(animated: true)
        }
        else{
            addMessage(withId: senderId, name: senderDisplayName, text: "Product store doesn't exist");
            SpeechManager.shared.speak(text: "Product store does not exist")
            finishReceivingMessage()
        }
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
            finishSendingMessage()
        }
    }
    
    private func addMedia(imageUrl: String, callBack: @escaping (() -> ()) ) {
        guard let url = URL(string: imageUrl) else { return }
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let data = data {
                DispatchQueue.main.async { [weak self] in
                    if let image = UIImage(data: data) {
                        self?.addImageMedia(image: image)
                        callBack()
                    }
                }
            } else {
                callBack()
            }
        }
        dataTask.resume()
    }
    
    private func addImageMedia(image: UIImage) {
        if let media = JSQPhotoMediaItem(image: image), let message = JSQMessage(senderId: senderIdentifier, displayName: displayName, media: media) {
            messages.append(message)
            finishSendingMessage()
        }
    }
    
    private func defaultHandling(response: AIResponse) {
        guard let textResponse = response.result.fulfillment.speech else { return }
        SpeechManager.shared.speak(text: textResponse)
        addMessage(withId: senderId, name: senderDisplayName, text: textResponse)
    }
}


// MARK: Speech Manager delegate

extension ChatViewController:SpeechManagerDelegate {
    func didStartedListening(status:Bool) {
        if status {
            self.inputToolbar.contentView.textView.text = initialStatement
        }
    }
    
    func didReceiveText(text: String) {
        self.inputToolbar.contentView.textView.text = text
        if text != initialStatement {
            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        }
    }
}
