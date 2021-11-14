//
//  ViewController.swift
//  TimerApp-itr1
//
//  Created by Aisha Ali on 10/17/21.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
  
  
  private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var quetionLabel: UILabel!
  @IBOutlet weak var timer: UIProgressView!
  
  var messagesString = [String]()
  var fullMessageString = ""
  var singleMessageString = ""
  var finalCommands = ""
  var name = "NULL"
  var isSetName = false
  var timer1:Timer!
  
  var cookingTimer:Timer = Timer()
  var denteTime: Int =  160
  var normalTime: Int = 15
  var secondsLeft = 0
  var player:AVAudioPlayer?
  var secondsPassed = 0
  var totalTime = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    speechRecognizer?.delegate = self

    
  }
  //MARK: -
  
  private func startRecording() throws {
    
    recognitionTask?.cancel()
    self.recognitionTask = nil
    
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    let inputNode = audioEngine.inputNode
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
    recognitionRequest.shouldReportPartialResults = true
    
    if #available(iOS 13, *) {
      recognitionRequest.requiresOnDeviceRecognition = false
    }
    
    recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest) { result, error in
      
      var isFinal = false
      isFinal = false
      if let result = result {
        self.singleMessageString = self.fullMessageString
        isFinal = result.isFinal
        let word = result.bestTranscription.formattedString
        self.fullMessageString = word
        let lastWord = self.fullMessageString.replacingOccurrences(of: self.singleMessageString, with: "")
        
   
        
        //MARK: - calling Type of Functions depending on Type of boyling
        
        if (lastWord.contains("Cool") || lastWord.contains("cool")){
          self.boilingType(type: "Dente")
          self.stopRecording()
        }
        
        if (lastWord.contains("Normal") || lastWord.contains("normal")){
          self.boilingType(type: "Normal")
          self.stopRecording()
          
        }
        
        if (lastWord.contains("Cancel") || lastWord.contains("cancel")){
          self.boilingType(type: "Cancel")
          self.stopRecording()
        }
      }
      
      //MARK: - StopRecording
      if isFinal {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.recordButton.isEnabled = true
      }else if error == nil || isFinal {
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
  
  //MARK: - Boilling Type Function
  
  func boilingType(type:String ){
    
    cookingTimer.invalidate()
    
    let boilingType = type
    if boilingType == "Dente" || boilingType == "dente" {
      Voice().read(text: "You Choses Dente, the timer will set to 10 minutes")
      print("denteTime: \(denteTime)")
      quetionLabel.text = "Boilling pasta al dente"
      secondsLeft = denteTime
      cookingTimerStart()
      self.stopRecording()
      
    }
    
    if boilingType == "Normal" || boilingType == "normal"  {
      Voice().read(text: "You Choses Normal, the timer will set to 15 minutes")

      print("normalTime: \(normalTime)")
      quetionLabel.text = "Boilling pasta normal time"
      secondsLeft = normalTime
      cookingTimerStart()
      self.stopRecording()
      
    }
    if boilingType == "Cancel" || boilingType == "cancel" {
      Voice().read(text: "Timer CANCELED")
      print("Timer CANCELLED")
      quetionLabel.text = "Timer Canceled"
      self.timer.setProgress(0, animated: false)
      self.player?.stop()
      self.stopRecording()
    }
  }
  
  //MARK: - CookingTimerStart()
  
  func cookingTimerStart(){
    cookingTimer = Timer.scheduledTimer(timeInterval: 1.00
                                        , target: self
                                        , selector: #selector(updateTimer)
                                        , userInfo: nil
                                        , repeats: true)
    self.timer.setProgress(0, animated: false)
    player?.stop()
  }
  
  
  @objc func updateTimer (){
    
    if secondsLeft > 0 {
      timer.setProgress(Float(secondsLeft), animated: true)
      print("\(secondsLeft) seconds.")
      secondsLeft -= 1
      
    }else {
      playSound(soundName: "alarm")
      cookingTimer.invalidate()
      Voice().read(text: "TIME IS OVER! Please Remove pot from the heat ")
      quetionLabel.text = "TIME IS OVER! \n Remove pot from heat "
    }
  }
  
  
  func calaculateAverage(name: String){
    if name == "Normal"{
      totalTime = 660
      secondsPassed = secondsLeft
      if secondsLeft > 0 {
        timer.setProgress(Float(secondsLeft), animated: true)
        print("\(secondsLeft) seconds.")
        secondsLeft -= 1
        let percentageProgress = secondsPassed / totalTime
        timer.progress = Float(percentageProgress)
      }
    }
  }
  
  
  func playSound(soundName: String) {
    guard let url = Bundle.main.url(forResource: soundName,withExtension: "mp3")
    else {
      return
    }
    do {
      try AVAudioSession.sharedInstance()
        .setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance()
        .setActive(true)
      player = try AVAudioPlayer(contentsOf: url)
      guard let player = player else {
        return
      }
      player.play()
    } catch let error {
      print("ERROR: The audio does not work.\n\(error.localizedDescription)")
    }
  }
  
  @IBAction func recordButton(_ sender: UIButton) {
    print("Button pressed")
    if audioEngine.isRunning {
      audioEngine.stop()
      recognitionRequest?.endAudio()
      recordButton.isEnabled = false
      recordButton.setTitle("Stopping", for: .disabled)
    } else {
      do {
        try startRecording()
        recordButton.setTitle("Stop Recording", for: [])
      } catch {
        recordButton.setTitle("Recording Not Available", for: [])
      }
    }
  }
  
  func stopRecording() {
    timer1?.invalidate()
    timer1 = Timer.scheduledTimer(withTimeInterval:0.5, repeats: false, block: {
      (timer) in
      self.audioEngine.stop()
      self.audioEngine.inputNode.removeTap(onBus: 0)
      
      self.recognitionRequest = nil
      self.recognitionTask = nil
      
      self.recordButton.isEnabled = true
    })
  }

  
}
