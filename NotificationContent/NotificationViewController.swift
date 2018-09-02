//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by Ashis Laha on 9/2/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
        if let imageUrl = notification.request.content.attachments.first?.url {
            print("imageUrl: ",imageUrl)
            guard let data = try? Data(contentsOf: imageUrl) else { return }
            imageView.image = UIImage(data: data)
        }
    }

}
