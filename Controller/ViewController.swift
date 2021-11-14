/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The root view controller that provides a button to start and stop recording, and which displays the speech recognition results.
 */

import UIKit
import Speech
import AVFoundation

public class ViewController: UIViewController, SFSpeechRecognizerDelegate {
  // MARK: Properties
  
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  
  let synthesizer = AVSpeechSynthesizer()
  
  var speed: Float = 0.5
  var timer: Timer!
  var messagesString = [String]()
  var fullMessageString = ""
  var singleMessageString = ""
  var finalCommands = ""
  
  var name = "NULL"
  var isSetName = false
  
  
  
  @IBOutlet var textView: UITextView!
  
  @IBOutlet var recordButton: UIButton!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var pauseButton: UIButton!
  @IBOutlet weak var resumeButton: UIButton!
  
  @IBOutlet weak var speedLabel: UILabel!
  @IBOutlet weak var sliderOutlet: UISlider!
  @IBOutlet weak var headView: UIView!
  
  // MARK: View Controller Lifecycle
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    headView.isHidden = true
    
    speedLabel.text = String(speed)
    sliderOutlet.value = speed
    
    recordButton.isEnabled = false
    buttonsConfiguration()
    stopRecording()
    
  }
  
  
  @IBAction func start(_ sender: UIButton) {
    let Utterance = AVSpeechUtterance(string: textView.text)
    Utterance.rate = speed
    synthesizer.speak(Utterance)
  }
  
  
  @IBAction func stop(_ sender: UIButton) {
    synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
  }
  
  
  @IBAction func pause(_ sender: UIButton) {
    synthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
  }
  
  
  @IBAction func resume(_ sender: UIButton) {
    synthesizer.continueSpeaking()
  }
  
  
  @IBAction func voiceSpeed(_ sender: UISlider) {
    speedLabel.text = String(format: "%.1f", sender.value)
    speed = sender.value
  }
  
  
  func buttonsConfiguration(){
    
    startButton.layer.borderColor = UIColor.white.cgColor
    startButton.layer.borderWidth = 3
    startButton.layer.cornerRadius = 15
    startButton.layer.masksToBounds = true
    
    stopButton.layer.borderColor = UIColor.white.cgColor
    stopButton.layer.borderWidth = 3
    stopButton.layer.cornerRadius = 15
    stopButton.layer.masksToBounds = true
    
    pauseButton.layer.borderColor = UIColor.white.cgColor
    pauseButton.layer.borderWidth = 3
    pauseButton.layer.cornerRadius = 15
    pauseButton.layer.masksToBounds = true
    
    resumeButton.layer.borderColor = UIColor.white.cgColor
    resumeButton.layer.borderWidth = 3
    resumeButton.layer.cornerRadius = 15
    resumeButton.layer.masksToBounds = true
    
    textView.layer.borderColor = UIColor.white.cgColor
    textView.layer.cornerRadius = 20
    textView.layer.borderWidth = 3
    
    recordButton.layer.borderColor = UIColor.white.cgColor
    recordButton.layer.cornerRadius = 20
    recordButton.layer.borderWidth = 3
    
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
          self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
          
        case .restricted:
          self.recordButton.isEnabled = false
          self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
          
        case .notDetermined:
          self.recordButton.isEnabled = false
          self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
          
        default:
          self.recordButton.isEnabled = false
        }
      }
    }
  }
  
  
  private func startRecording() throws {
    
    // Cancel the previous task if it's running.
    recognitionTask?.cancel()
    self.recognitionTask = nil
    
    // Configure the audio session for the app.
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    let inputNode = audioEngine.inputNode
    
    // Create and configure the speech recognition request.
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
    recognitionRequest.shouldReportPartialResults = true
    
    // Keep speech recognition data on device
    if #available(iOS 13, *) {
      recognitionRequest.requiresOnDeviceRecognition = false
    }
    
    // Create a recognition task for the speech recognition session.
    // Keep a reference to the task so that it can be canceled.
    recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
      var isFinal = false
      isFinal = false
      if let result = result {
        self.singleMessageString = self.fullMessageString
        // Update the text view with the results.
        //                self.textView.text = result.bestTranscription.formattedString
        isFinal = result.isFinal
        let word = result.bestTranscription.formattedString
        self.fullMessageString = word
        self.textView.text = word
        
      }
      
      if isFinal {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.recordButton.isEnabled = true
        self.recordButton.setTitle("Speak up!", for: [])
      }
      else
        if error == nil || isFinal {
          self.stopRecording()
          
          self.headView.isHidden = false
        }
    }
    
    // Configure the microphone input.
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat)
    { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    try audioEngine.start()
  }
  
  
  func stopRecording() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1.5,
                                 repeats: false, block: { (timer) in
      self.audioEngine.stop()
      self.audioEngine.inputNode.removeTap(onBus: 0)
      
      self.recognitionRequest = nil
      self.recognitionTask = nil
      
      self.recordButton.isEnabled = true
      self.recordButton.setTitle("Speak up!", for: [])
    })
  }
  
  // MARK: SFSpeechRecognizerDelegate
  
  func textTalk(_ text:String , _ local:String){
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: local)
    let synthesizer = AVSpeechSynthesizer()
    if synthesizer.isSpeaking {
      synthesizer.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
      synthesizer.speak(utterance)
      
    } else {
      synthesizer.speak(utterance)
    }
    
  }
  
  @objc func setName(_ name:String){
    self.isSetName = false
    self.name = name
    self.textView.text = "Your Name is \(name)\nI will remember that"
    self.textTalk("Your Name is \(name)\n,I will remember that", "en-GB")
  }
  
  
  public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if available {
      recordButton.isEnabled = true
      recordButton.setTitle("Speak up!", for: [])
    } else {
      recordButton.isEnabled = false
      recordButton.setTitle("Recognition Not Available", for: .disabled)
    }
  }
  
  // MARK: Interface Builder actions
  
  @IBAction func recordButtonTapped() {
    if audioEngine.isRunning {
      audioEngine.stop()
      recognitionRequest?.endAudio()
      recordButton.isEnabled = false
      recordButton.setTitle("Stopping", for: .disabled)
    } else {
      do {
        try startRecording()
        recordButton.setTitle("Stopped", for: [])
      } catch {
        recordButton.setTitle("Recording Not Available", for: [])
      }
    }
  }
}

