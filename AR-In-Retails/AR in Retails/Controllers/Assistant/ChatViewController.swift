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
    func navigate(to: String)
}


class ChatViewController: JSQMessagesViewController {
    
    public var isUserInsideStore: Bool = false // this flag is caputured to restrict few queries to the users
    private let senderIdentifier = "walmart chat bot"
    private let displayName = "Wal-E"
    private let userId = "userId"
    private let userName = "user_name"
    
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    lazy var speechSynthesizer = AVSpeechSynthesizer()
    
    weak var delegate: ChatDelegate?
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = senderIdentifier
        self.senderDisplayName = displayName
        
        SpeechManager.shared.delegate = self
        self.addMicButton()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.populateWithWelcomeMessage()
        })
    }
    
    func addMicButton() {
        let height = self.inputToolbar.contentView.leftBarButtonContainerView.frame.size.height
        let micButton = UIButton(type: .custom)
        micButton.setImage(#imageLiteral(resourceName: "microphone"), for: .normal)
        micButton.frame = CGRect(x: 0, y: 0, width: 25, height: height)
        
        inputToolbar.contentView.leftBarButtonItemWidth = 25
        inputToolbar.contentView.leftBarButtonContainerView.addSubview(micButton)
        inputToolbar.contentView.leftBarButtonItem.isHidden = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOfMic(gesture:)))
        micButton.addGestureRecognizer(longPressGesture)
    }
    
    func populateWithWelcomeMessage() {
        addMessage(withId: senderId, name: senderDisplayName, text: "Hi I am Wal-Bot")
        finishReceivingMessage()
        addMessage(withId: senderId, name: senderDisplayName, text: "I am here to help you about Walmart e-commerce and retail")
        finishReceivingMessage()
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @objc func handleLongPressOfMic(gesture:UILongPressGestureRecognizer) {
        if gesture.state == .began {
            SpeechManager.shared.startRecording()
        } else if gesture.state == .ended {
            SpeechManager.shared.stopRecording()
            if inputToolbar.contentView.textView.text == "Say something, I'm listening!" {
                inputToolbar.contentView.textView.text = ""
            }
        }
    }
    
    //MARK: Core Functionality
    func performQuery(senderId:String,name:String,text:String) {
        guard !text.isEmpty else { return }
        let request = ApiAI.shared().textRequest()
        request?.query = text
        
        request?.setMappedCompletionBlockSuccess({ [weak self] (request, response) in
            guard let response = response as? AIResponse, let strongSelf = self else { return }
            // check the messages in fullfillment response
            
            if let textResponse = response.result.fulfillment.speech {
                if response.result.action == "input.navigation"{
                    if let dest = StoreModel().productToNodeInt[textResponse] {
                        SpeechManager.shared.speak(text: "Navigating to " + textResponse)
                        strongSelf.addMessage(withId: "BotId", name: "Bot", text: textResponse)
                        strongSelf.finishReceivingMessage()
                        strongSelf.delegate?.navigate(to: textResponse)
                        strongSelf.navigationController?.popViewController(animated: true)
                    }
                    else{
                        strongSelf.addMessage(withId: "BotId", name: "Bot", text: "Product store doesn't exist");
                        SpeechManager.shared.speak(text: "Product store does not exist")
                        strongSelf.finishReceivingMessage()
                    }
                } else {
                    SpeechManager.shared.speak(text: textResponse)
                    strongSelf.addMessage(withId: "BotId", name: "Bot", text: textResponse)
                    strongSelf.finishReceivingMessage()
                }
                
            }
        }, failure: { (request, error) in
            print(error?.localizedDescription)
        })
        ApiAI.shared().enqueue(request)
    }
    
    //MARK: JSQMessageViewController Methods
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
    
    //removing avatars
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell else { return UICollectionViewCell() }
        let message = messages[indexPath.item]
        cell.textView?.textColor = message.senderId == senderId ? UIColor.white: UIColor.black
        return cell
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        addMessage(withId: userId, name: userName, text: text!)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        performQuery(senderId: userId, name: userName, text: text!)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        performQuery(senderId: userId, name: userName, text: "Multimedia")
    }
}
extension ChatViewController:SpeechManagerDelegate {
    func didStartedListening(status:Bool) {
        if status {
            self.inputToolbar.contentView.textView.text = "Say something, I'm listening!"
        }
    }
    
    func didReceiveText(text: String) {
        self.inputToolbar.contentView.textView.text = text
        if text != "Say something, I'm listening!" {
            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        }
    }
}
