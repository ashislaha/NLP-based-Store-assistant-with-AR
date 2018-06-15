//
//  DialogflowViewController.swift
//  AR in Retails
//
//  Created by Rishabh Mishra on 03/06/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import UIKit
import ApiAI
import AVFoundation
import Speech

class DialogflowViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()


    //@IBOutlet weak var lblResponse: UILabel!
    @IBOutlet weak var textViewResponse: UITextView!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var microphoneButton: UIButton!
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        microphoneButton.isEnabled = false  //2
        
        speechRecognizer?.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }

        // Do any additional setup after loading the view.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        //self.view.frame.origin.y -= 150
    }
    
    @IBAction func microphoneTapped(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            //microphoneButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            //microphoneButton.setTitle("Stop Recording", for: .normal)
        }
    }
    @IBAction func askPressed(_ sender: Any) {
        
        let request = ApiAI.shared().textRequest()
        
        if let text = self.txtField.text, text != "" {
            request?.query = text
        } else {
            return
        }
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            if let textResponse = response.result.fulfillment.speech {
                self.speechAndText(text: textResponse)
            }
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
        txtField.text = ""
        
        self.microphoneTapped(microphoneButton)
        
    }
    
    
    private func addRightBarButtonItems() {
        let barbuttonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(tappedARView))
        
        let barbuttonItem2 = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tappedDialogflowView))
        
        navigationItem.rightBarButtonItems = [barbuttonItem2]
        
    }
    @objc func tappedARView() {
        pushARVC()
    }
    
    @objc func tappedDialogflowView() {
        pushDFVC()
    }
    
    public func pushDFVC() {
        guard let dfVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DialogflowViewController") as? DialogflowViewController else { return }
        navigationController?.pushViewController(dfVC, animated: true)
    }
    
    public func pushARVC() {
        guard let ARVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ARViewController") as? ARViewController else { return }
        navigationController?.pushViewController(ARVC, animated: true)
    }
    
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    func speechAndText(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speak(speechUtterance)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.textViewResponse.text = text
        }, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.txtField.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
                //self.microphoneTapped(audioSession)
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        txtField.text = "Say something, I'm listening!"
        
    }

    

}
