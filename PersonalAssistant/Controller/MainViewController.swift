//
//  CollectionViewController.swift
//  SpokenWord
//
//  Created by Marzouq Almukhlif on 05/04/1443 AH.
//  Copyright © 1443 Apple. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import WebKit
var local = UserDefaults.standard.string(forKey: "local") ?? "en-US"

var theData: [MyCommandTextModel] = []

@available(iOS 13.0, *)
class MainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, SFSpeechRecognizerDelegate,WKNavigationDelegate {
  
  // MARK: Properties
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: local))!
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet var recordButton: UIButton!

  
  // MARK: - My Properties
  var command: Commands!
  var messagesString = [String]()
  var webView = WKWebView(frame: UIScreen.main.bounds)
  
  var fullMessageString = ""
  var singleMessageString = ""
  var name = ""
  var timer:Timer!
  var isSearch = false
  
  
  
  // MARK: - View Controller Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    command = Commands(tableView: self.tableView, thedata: theData)
    
    
    if (command.name == nil) {
      let msgName = NSLocalizedString("Hello, what do you want me to call you.\nPress the mic button and talk", comment: "msgNotSetName")
      command.talkToUser(msgName, local)
      name = "NULL"
    } else {
      name = command.name ?? "NULL"

      let msgWelcome = NSLocalizedString("Welcome %@", comment: "msgWelcome")
      let wantedString = String(format: msgWelcome, name)
      command.talkToUser(wantedString, local)

      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
        let msgHowAre = NSLocalizedString("How are you today", comment: "msgHowAre")
        self.command.talkToUser(msgHowAre, local)
      }
    }
    
    recordButton.isEnabled = false
    tableView.register(CommandCell.self, forCellReuseIdentifier: "ChatCell")
  }
  
  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // Configure the SFSpeechRecognizer object already
    // stored in a local member variable.
    speechRecognizer.delegate = self
    
    // Asynchronously make the authorization request.
    SFSpeechRecognizer.requestAuthorization { authStatus in
      
      // Divert to the app's main thread so that the UI
      // can be updated.
      OperationQueue.main.addOperation {
        switch authStatus {
        case .authorized:
          self.recordButton.isEnabled = true
        case .denied:
          self.recordButton.isEnabled = false
        case .restricted:
          self.recordButton.isEnabled = false
        case .notDetermined:
          self.recordButton.isEnabled = false
        default:
          self.recordButton.isEnabled = false
        }
      }
    }
  }
  
  
  private func startRecording() throws {
//    self.textView.text = "Say Help to show all Voice Commands"

    // Cancel the previous task if it's running.
    recognitionTask?.cancel()
    self.recognitionTask = nil
    
    // Configure the audio session for the app.
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)

    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    let inputNode = audioEngine.inputNode
    
    // Create and configure the speech recognition request.
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
    recognitionRequest.shouldReportPartialResults = true
    
    // Keep speech recognition data on device
      recognitionRequest.requiresOnDeviceRecognition = false
    
    
    // Create a recognition task for the speech recognition session.
    // Keep a reference to the task so that it can be canceled.
    recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest)
    { result, error in
      var isFinal = false
      isFinal = false
      if let result = result {
        self.singleMessageString = self.fullMessageString
        // Update the text view with the results.
        isFinal = result.isFinal
        let word = result.bestTranscription.formattedString
        self.fullMessageString = word
      }
      
      if isFinal {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.recordButton.isEnabled = true
        self.recordButton.setImage(UIImage(systemName: "mic.circle.fill"), for: [])
      }
      else if error == nil {
        self.stopRecording()
      }
    }

    
    // Configure the microphone input.
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    try audioEngine.start()
  }
  
  
  // MARK: - My Code
  func firstRun(_ text:String) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
      if self.messagesString.count > 1 {
        let titleAlert = NSLocalizedString("Choose correct", comment: "titleAlert")
        let msgAlert = NSLocalizedString("What is your correct name?", comment: "msgAlert")

        let alertController = UIAlertController(title: titleAlert, message: msgAlert, preferredStyle: .alert)
        for messgae in self.messagesString {
          let action = UIAlertAction(title: messgae, style: .default) {
            UIAlertAction in
            self.command.setName(messgae)
          }
          alertController.addAction(action)
        }
        let noneAlert = NSLocalizedString("none above", comment: "noneAlert")

        let action2 = UIAlertAction(title: noneAlert, style: .cancel) {
          UIAlertAction in
          let msgChangname = NSLocalizedString("Well, press the record button and say your name again", comment: "msgChangname")
          self.command.talkToUser(msgChangname, local)
          self.command.nameSeted = false
        }
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
      } else {
        self.command.setName(text)
      }
      
    }
  }
  
  func openWebKit() {
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
      self.webKitShow(self.fullMessageString)
    }
    
  }
  
  func webKitShow(_ text:String) {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "www.google.com"
    urlComponents.path = "/search"
    urlComponents.queryItems = [
      URLQueryItem(name: "q", value: text),
    ]
    
    
    let request = URLRequest(url:urlComponents.url!)
    self.webView.navigationDelegate = self // Add this line!
    webView.allowsBackForwardNavigationGestures = true
    self.webView.load(request)
    let controller = UIViewController()
    controller.view.frame = view.frame
    controller.view.addSubview(webView)
    self.present(controller,animated: true)
    
  }
  
  func stopRecording() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
      self.commandSSet()
      self.audioEngine.stop()
      self.audioEngine.inputNode.removeTap(onBus: 0)
      
      self.recognitionRequest = nil
      self.recognitionTask = nil
      
      self.recordButton.isEnabled = true
      self.recordButton.setImage(UIImage(systemName: "mic.circle.fill"), for: [])
    })

  }
  
  func addMessage(_ text:String ,_ incoming:Bool) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
      let newMessage =  MyCommandTextModel(incoming: incoming, command: text)
      theData.append(newMessage)
      self.tableView.reloadData()
      self.tableView.scroll(to: .bottom, animated: true)
    }
  }
  
  func commandSSet() {
    let lastWord = self.fullMessageString
    
    self.command.updateViewColor(lastWord.lowercased())
    print("~~~ \(self.fullMessageString)")
    if lastWord != "" {
      self.messagesString.append(lastWord)
    }
    self.addMessage(self.fullMessageString,false)

    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
          
    if (!self.command.nameSeted) {
      self.firstRun(lastWord)
    } else {
      let hi = NSLocalizedString("hi", comment: "hi")
      if (lastWord.lowercased().contains(hi) && lastWord.lowercased() == hi){
        self.command.commandCall(.hi)
      }
      let fine = NSLocalizedString("fine", comment: "fine")
      if (lastWord.lowercased().contains(fine) && !self.isSearch) {
        self.command.commandCall(.fine)
      }
      
      let search = NSLocalizedString("search", comment: "search")
      if ( lastWord.lowercased().contains(search) && !self.isSearch) {
        self.isSearch = true
        self.command.commandCall(.search)
      }
      
      if (self.isSearch && !lastWord.lowercased().contains(search) && lastWord != "" ) {
        self.isSearch = false
        self.openWebKit()
      }
      
      let photo = NSLocalizedString("photo", comment: "photo")

      if (lastWord.lowercased().contains(photo) && !self.isSearch) {
        self.command.commandCall(.photo)
      }
      
      let safari = NSLocalizedString("safari", comment: "safari")
      if (lastWord.lowercased().contains(safari) && !self.isSearch) {
        self.command.commandCall(.safari)
      }
      
      let messages = NSLocalizedString("messages", comment: "messages")
      if (lastWord.lowercased().contains(messages) && !self.isSearch) {
        self.command.commandCall(.messages)
      }
      
      let settings = NSLocalizedString("settings", comment: "settings")
      if (lastWord.lowercased().contains(settings) && !self.isSearch) {
        self.command.commandCall(.settings)
      }
      
      let help = NSLocalizedString("help", comment: "help")
      if (lastWord.lowercased().contains(help) && !self.isSearch) {
        self.command.commandCall(.help)
      }
      
      let howAreYou = NSLocalizedString("how are you", comment: "how are you")
      if (self.fullMessageString.lowercased().contains(howAreYou) && self.fullMessageString.lowercased() == howAreYou) {
        self.command.commandCall(.howAreYou)
      }
      
      let change = NSLocalizedString("change", comment: "change")
      let nameMs = NSLocalizedString("name", comment: "name")

      if (self.fullMessageString.lowercased().contains(change) && self.fullMessageString.lowercased().contains(nameMs) ) {
        self.command.commandCall(.changeName)
      }
      
      
    }
  }
  }
  
  
  // MARK: - SFSpeechRecognizerDelegate
  public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if available {
      recordButton.isEnabled = true
      recordButton.setImage(UIImage(systemName: "stop.circle.fill"), for: [])
    } else {
      recordButton.isEnabled = false
      recordButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .disabled)
    }
  }
  
  // MARK: - Interface Builder actions
  @IBAction func recordButtonTapped() {
    self.messagesString.removeAll()
    synthesizer.stopSpeaking(at: .immediate)

    if audioEngine.isRunning {
      audioEngine.stop()
      recognitionRequest?.endAudio()
      recordButton.isEnabled = false
    } else {
      do {
        try startRecording()
        recordButton.setImage(UIImage(systemName: "stop.circle.fill"), for: [])
      } catch {
        recordButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: [])
      }
    }
  }
  
  @IBAction func showCommanButton(_ sender: Any) {
    command.commandCall(.help)
  }
  
  @IBAction func aboutApp(_ sender: Any) {
    let titleAlert1 = NSLocalizedString("Developed by", comment: "titleAlert1")
    let msgAlert1 = NSLocalizedString("Marzouq Al-Mukhlif\nSponsored by Ignasi Perez-Valls\n\n© 2021 MarzouqAlmukhlif, All Rights Reserved", comment: "msgAlert1")

    let alertController = UIAlertController(title: titleAlert1, message: msgAlert1, preferredStyle: .alert)
    
    let actionAlert1 = NSLocalizedString("Thanks 🌹", comment: "actionAlert1")

      let action = UIAlertAction(title: actionAlert1, style: .cancel) {
        UIAlertAction in
      }
    
    let enAlert1 = NSLocalizedString("English", comment: "enAlert1")
      let actionEn = UIAlertAction(title: enAlert1, style: .default) {
        UIAlertAction in
        UserDefaults.standard.setValue("en-US", forKey: "local")
        local = "en-US"
        
        
      }
    
    let arAlert1 = NSLocalizedString("Arabic", comment: "arAlert1")
      let actionAr = UIAlertAction(title: arAlert1, style: .default) {
        UIAlertAction in
        UserDefaults.standard.setValue("ar-SA", forKey: "local")
        local = "ar-SA"

      }
    
    alertController.addAction(actionAr)
    alertController.addAction(actionEn)
    alertController.addAction(action)

    self.present(alertController, animated: true, completion: nil)

  }
  
  
  
  // MARK: - UITableViewDelegate
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return theData.count
  }
  
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! CommandCell
    cell.selectionStyle = .none
    cell.setData(theData[indexPath.row])
    cell.backgroundColor = .clear
    return cell
  }
  
  
}
