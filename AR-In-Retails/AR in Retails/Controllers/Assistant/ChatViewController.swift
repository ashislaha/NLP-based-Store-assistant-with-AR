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

class ChatViewController: JSQMessagesViewController {
    
    public var isUserInsideStore: Bool = false // this flag is caputured to restrict few queries to the users
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    lazy var speechSynthesizer = AVSpeechSynthesizer()
    
    //MARK: Lifecycle Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.senderId = "some userId"
        self.senderDisplayName = "some userName"
        
        SpeechManager.shared.delegate = self
        self.addMicButton()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        let deadlineTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.populateWithWelcomeMessage()
        })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Helper Methods
    func addMicButton() {
        let height = self.inputToolbar.contentView.leftBarButtonContainerView.frame.size.height
        let micButton = UIButton(type: .custom)
        micButton.setImage(#imageLiteral(resourceName: "microphone"), for: .normal)
        micButton.frame = CGRect(x: 0, y: 0, width: 25, height: height)
        
        self.inputToolbar.contentView.leftBarButtonItemWidth = 25
        self.inputToolbar.contentView.leftBarButtonContainerView.addSubview(micButton)
        self.inputToolbar.contentView.leftBarButtonItem.isHidden = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOfMic(gesture:)))
        micButton.addGestureRecognizer(longPressGesture)
    }
    
    func populateWithWelcomeMessage() {
        self.addMessage(withId: "BotId", name: "Bot", text: "Hi I am Wal-Bot")
        self.finishReceivingMessage()
        self.addMessage(withId: "BotId", name: "Bot", text: "I am here to help you about Walmart e-commerce and retail")
        self.finishReceivingMessage()
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //MARK: Gesture Handler Methods
    @objc func handleLongPressOfMic(gesture:UILongPressGestureRecognizer) {
        if gesture.state == .began {
            SpeechManager.shared.startRecording()
        }
        else if gesture.state == .ended
        {
            SpeechManager.shared.stopRecording()
            if inputToolbar.contentView.textView.text == "Say something, I'm listening!"
            {
                inputToolbar.contentView.textView.text = ""
            }
        }
    }
    
    //MARK: Core Functionality
    func performQuery(senderId:String,name:String,text:String) {
        let request = ApiAI.shared().textRequest()
        if text != "" {
            request?.query = text
        } else {
            return
        }
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            
            /*
             // this below section is not used here
            if response.result.action == "tell.about" {
                if let parameters = response.result.parameters as? [String:AIResponseParameter] {
                    if let about = parameters["about"]?.stringValue {
                        switch about {
                        case "Kings":
                            print("Kings")
                        case "Heat":
                            print("Heat")
                        default:
                            print("Default")
                        }
                    }
                }
            } else if response.result.action == "tell.stats" {
                if let parameters = response.result.parameters as? [String:AIResponseParameter] {
                    if let stats = parameters["stats"]?.stringValue {
                        switch stats {
                        case "Lead":
                            print("Lead")
                        default:
                            print("Default")
                        }
                    }
                }
            } else if response.result.action == "bot.capabilities" {
                if let parameters = response.result.parameters as? [String:AIResponseParameter] {
                    if let capabilities = parameters["capabilities"]?.stringValue {
                        switch capabilities {
                        case "multimedia":
                            print("multimedia")
                        default:
                            print("Default")
                        }
                    }
                }
            } else if response.result.action == "bot.quit" {
                if let parameters = response.result.parameters as? [String:AIResponseParameter] {
                    if let quit = parameters["quit"]?.stringValue {
                        let deadlineTime = DispatchTime.now() + .seconds(2)
                        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                            self.minimiseBot()
                        })
                    }
                }
            } else {
                print("Unknown")
            }
            */
            
            //response.result.fulfillment.
            
            
            if let textResponse = response.result.fulfillment.speech {
                if response.result.action == "input.navigation"{
                    SpeechManager.shared.speak(text: "Navigating to " + textResponse)
                    
                }
                else{
                SpeechManager.shared.speak(text: textResponse)
                self.addMessage(withId: "BotId", name: "Bot", text: textResponse)
                self.finishReceivingMessage()
                }
            }
        }, failure: { (request, error) in
            print(error)
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
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    //removing avatars
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        addMessage(withId: senderId, name: senderDisplayName!, text: text!)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        performQuery(senderId: senderId, name: senderDisplayName, text: text!)
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton)
    {
        performQuery(senderId: senderId, name: senderDisplayName, text: "Multimedia")
        
    }
}
extension ChatViewController:SpeechManagerDelegate
{
    func didStartedListening(status:Bool)
    {
        if status
        {
            self.inputToolbar.contentView.textView.text = "Say something, I'm listening!"
        }
    }
    
    func didReceiveText(text: String)
    {
        self.inputToolbar.contentView.textView.text = text
        
        if text != "Say something, I'm listening!"
        {
            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        }
    }
}
