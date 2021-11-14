

import UIKit
import MapKit
import Speech
import AVFoundation

class MapViewController: UIViewController,
                         MKMapViewDelegate,
                         SFSpeechRecognizerDelegate {
  
  var player: AVAudioPlayer?
  
  var userInputLocation = FlyoverAwesomePlace.newYorkStatueOfLiberty
  
  let speechRecognizer: SFSpeechRecognizer?
  = SFSpeechRecognizer(locale: Locale.init(identifier:"en-GB"))
  var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  var recognitionTask: SFSpeechRecognitionTask?
  let audioEngine = AVAudioEngine()
  
  var timer:Timer!
  
  @IBOutlet weak var mapView: MKMapView!
  
  @IBOutlet weak var locationButton: UIButton!
  
  @IBOutlet weak var placeLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    playRecordInstructionMessageeSound()
    
    speechRecognizer?.delegate = self
    SFSpeechRecognizer.requestAuthorization{
      status in
      var buttonState = false
      switch status {
      case .authorized:
        buttonState = true
      case .notDetermined:
        buttonState = false
      case .denied:
        buttonState = false
      case .restricted:
        buttonState = false
      default:
        break
      }
      
      DispatchQueue.main.async {
        self.locationButton.isEnabled = buttonState
      }
    }
    
    mapSetUp()
  }
  
  
  func startRecording() {
    if recognitionTask != nil {
      recognitionTask?.cancel()
      recognitionTask = nil
    }
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.record,
                                   mode: .measurement,
                                   options: .duckOthers)
      try audioSession.setActive(true,
                                 options: .notifyOthersOnDeactivation)
    }
    catch{
    }
    
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    let inputNode = audioEngine.inputNode
    guard let recognitionRequest = recognitionRequest else {
      fatalError()
    }
    
    
    recognitionRequest.shouldReportPartialResults = true
    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) {
      result, error in
      var isLast = false
      if result != nil {
        isLast = (result?.isFinal)!
      }
      
      if error != nil || isLast {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.locationButton.isEnabled = true
        let bestTranscription = result?.bestTranscription.formattedString
        var inDictionary = self.locationDictionary.contains {
          $0.key == bestTranscription
          
        }
        
        if inDictionary {
          self.placeLabel.text = bestTranscription
          self.userInputLocation = self.locationDictionary[bestTranscription!]!
        }
        else {
          self.placeLabel.text = "Can't find that in dictionary"
          self.userInputLocation = FlyoverAwesomePlace.parisEiffelTower
        }
        self.mapSetUp()
      }
    }
    
    let format = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0,
                         bufferSize: 1024,
                         format: format) {
      buffer, _ in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    
    do{
      try audioEngine.start()
    }
    catch {
      
    }
  }
  
  
  
  @IBAction func locationButtonPressed(_ sender: UIButton) {
    if audioEngine.isRunning {
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        self.locationButton.isEnabled = false
        self.locationButton.setTitle("Record", for: .normal)
      }else{
      startRecording()
      locationButton.setTitle("Stop", for: .normal)
    }
  }
  
  func mapSetUp() {
    mapView.mapType = .hybridFlyover
    mapView.showsBuildings = true
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
    
    let camera = FlyoverCamera(mapView: self.mapView,
                               configuration: FlyoverCamera.Configuration(duration: 7.0,
                                                                          altitude: 300,
                                                                          pitch: 45.0,
                                                                          headingStep: 20.0))
    camera.start(flyover: self.userInputLocation)
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(9),
                                  execute: {
      camera.stop()
    })
  }
  
  
  let locationDictionary = [
    "Statue of Liberty": FlyoverAwesomePlace.newYorkStatueOfLiberty,
    "Big Ben": FlyoverAwesomePlace.londonBigBen,
    "London Eye": FlyoverAwesomePlace.londonEye,
    "Sydney Opera House": FlyoverAwesomePlace.sydneyOperaHouse,
    "Sagrada Familia": FlyoverAwesomePlace.sagradaFamiliaSpain,
    "Apple HQ": FlyoverAwesomePlace.appleHeadquarter,
    "pizza di Trevi": FlyoverAwesomePlace.piazzaDiTrevi,
    "Paris Eiffel Tower": FlyoverAwesomePlace.parisEiffelTower,
    "Miami Beach": FlyoverAwesomePlace.miamiBeach,
    "Dubai Burj Khalifa": FlyoverAwesomePlace.dubaiBurjKhalifa
   
  ]
  
  
  func playRecordInstructionMessageeSound() {
    guard let url = Bundle.main.url(forResource: "RecordInstructionMessage",
                                    withExtension: "mp3") else { return }
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback,mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
      
      player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
      
      guard let player = player else { return }
      player.play()
      
    } catch let error {
      print(error.localizedDescription)
    }
  }
  
  func stopRecordInstructionMessageSound() {
    player?.stop()
  }
}

