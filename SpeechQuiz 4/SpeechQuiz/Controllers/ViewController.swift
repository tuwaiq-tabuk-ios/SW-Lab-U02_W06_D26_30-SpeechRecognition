

import UIKit
import Speech
import AVFoundation

public class ViewController: UIViewController, SFSpeechRecognizerDelegate {
  
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
   private var recognitionTask: SFSpeechRecognitionTask?
   private let audioEngine = AVAudioEngine()
   private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var speechButton: UIButton!
  
  var messagesString = [String]()
  var fullMessageString = ""
  var singleMessageString = ""
  var finalCommands = ""
  var player: AVAudioPlayer?
  var question = "NULL"
  var isSetQuestion1 = false
  var isSetName = false
  var timer:Timer!
 
  var name = ""
  
  public override func viewDidLoad() {
    super.viewDidLoad()
   
    WelcomeSentence().talkToUserQuestions()
    speechButton.isEnabled = false
    
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    speechRecognizer.delegate = self
    
    SFSpeechRecognizer.requestAuthorization{  requestStatus in
      OperationQueue.main.addOperation {
        switch requestStatus  {
          
        case.authorized:
          self.speechButton.isEnabled = true
          
        case.denied:
          self.speechButton.isEnabled = false
          self.speechButton.setTitle("User denied access to speech recognition",for: .disabled)
          
        case .restricted:
          self.speechButton.isEnabled = false
          self.speechButton.setTitle("Speech recognition restricted on this device",for: .disabled)
          
        case .notDetermined:
          self.speechButton.isEnabled = false
          self.speechButton.setTitle("Speech recognition not yet authorized",for: .disabled)
          
        default:
          self.speechButton.isEnabled = false
        }
      }
    }
  }
  
 
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
    
    
recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
  var isFinal = false
  isFinal = false
 if let result = result {
   self.textView.text = result.bestTranscription.formattedString
    isFinal = result.isFinal
    
   let word = result.bestTranscription.formattedString
     self.fullMessageString = word
     self.textView.text = word
        
 let lastWord = self.fullMessageString.replacingOccurrences(of: self.singleMessageString, with: "")
  
   if self.isSetName == false {

          if(lastWord.contains("Start") || lastWord.contains("start")){

            self.textView.text = word

            if (self.name != "NULL" && self.name != "") {

              self.textView.text = " \(self.name)"
             Commands().textTalk("Start \(self.name)", "en-GB")
            } else {
              self.textView.text = ""
              Commands().textTalk("Ok let's start say first question","en-GB")
              DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.isSetName = true
           }
        }
      }
   }
   
   
if (lastWord.contains("first") || lastWord.contains("First")) {
  Commands().textTalk("What is the capital of Saudi Arabia?","en-US")}

if (lastWord.contains("riyadh") || lastWord.contains("Riyadh")) {
  Commands().textTalk("correct you are amazing \(self.playSound(soundName: "clap",audioStretch: "wav"))) /n say second ","en-US") }

 if (lastWord.contains("second") || lastWord.contains("Second")) {
    Commands().textTalk("What is the capital of the Emirates?","en-US") }

 if (lastWord.contains("beirut") || lastWord.contains("Beirut")) {
   Commands().textTalk("incorrect answer \(self.playSound(soundName: "fail", audioStretch: "mp3"))","en-US") }
  
     }
      
      if isFinal {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)

        self.recognitionRequest = nil
        self.recognitionTask = nil

        self.speechButton.isEnabled = true
        self.speechButton.setTitle("Start Recording", for: [])
      } else
      if error == nil || isFinal{

      }
    }
    
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
      (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    try audioEngine.start()
    self.textView.text = "You can speak now"
  }
  
  
    //  MARK - action speech button
  @IBAction func speechButtonPressed(_ sender: UIButton) {
    if audioEngine.isRunning {
      audioEngine.stop()
      recognitionRequest?.endAudio()
      speechButton.isEnabled = false
      speechButton.setTitle("Stopping", for: .disabled)
    } else {
      do {
        try startRecording()
        speechButton.setTitle("", for: [])
      } catch {
        speechButton.setTitle("Recording Not Available", for: [])
      }
    }
  }
  

  func stopRecording() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 6.5, repeats: false, block: { (timer) in
      })
   }
  
  
  // MARK - the sound function
  func playSound(soundName: String ,audioStretch: String) {
    guard let url = Bundle.main.url(forResource: soundName , withExtension: audioStretch)
    else { return
      
    }
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
      
      player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
      
      guard let player = player else {
        return
      }
      player.play()
      
    } catch let error {
      print("ERROR: The audio does not work.\n \(error.localizedDescription)")
    }
  }
 }

