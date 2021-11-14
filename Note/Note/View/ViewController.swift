//
//  ViewController.swift
//  Note
//
//  Created by Ressam Al-Thebailah on 05/04/1443 AH.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController {
    let synth = AVSpeechSynthesizer()
   
      let control = Controller()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var  textToSpeak = ""
    var listeningText = ""
    var x = 0
    var isAddingNote = false
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet weak var recordButton: UIButton!
    
    
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
                    self.synth.speak(AVSpeechUtterance(string: "User denied access to speech recognition"))
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    self.synth.speak(AVSpeechUtterance(string: "Speech recognition restricted on this device"))
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                    self.synth.speak(AVSpeechUtterance(string: "Speech recognition not yet authorized"))
                default:
                    self.recordButton.isEnabled = false
                }
            }
        }
    }
  
    
    @IBAction func btnAction(_ sender: UIButton) {
       handleStartRecording()
    }
    
    func handleStartRecording()
      {
          if !synth.isSpeaking
          {
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
      }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
   //   synth.delegate = self
   
        textToSpeak = "Welcome To your daily notes You Have \(self.control.notes.count) Notes What Do You Want To Do?"
      textToSpeak += " To Listen To your Notes say one "
      
      //  to add note Say two ,to Delete Note say Three ,to update note say four
      let speakUtterance = AVSpeechUtterance(string: textToSpeak)
      synth.speak(speakUtterance)
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
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [self] result, error in
            var isFinal = false
            var addNoteText = ""
            if let result = result {
                // Update the text view with the results.
                self.listeningText = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if isAddingNote == false
                {
                    self.listeningText = result.bestTranscription.formattedString
                }else
                {
                    addNoteText = result.bestTranscription.formattedString
                    print("This is AddNoteVoice" + addNoteText)
                }
              
                if !addNoteText.isEmpty
                {
                    var nodeNumber = 0
                   if self.control.getLastNoteNumber() != -1
                   {
                       nodeNumber = self.control.getLastNoteNumber() + 1
                   }
                   self.control.addNote(note: Note(number: nodeNumber, text: addNoteText))
                   self.synth.speak(AVSpeechUtterance(string: "Note Added Succssfully"))
                    isAddingNote = false
                }

                if !self.listeningText.isEmpty
                {
                
                    recognitionTask?.cancel()
                   self.audioEngine.stop()
                    self.recognitionRequest?.endAudio()

                        self.clientChose()
 
                }
               //////////////////////////////////////
                }
                isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")

            }

        
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start Recording", for: [])
            }
           
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
        
    }
    

}



extension ViewController :  SFSpeechRecognizerDelegate {
  
  
  
  public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
      if available {
          recordButton.isEnabled = true
          recordButton.setTitle("Start Recording", for: [])
      } else {
          recordButton.isEnabled = false
          recordButton.setTitle("Recognition Not Available", for: .disabled)
      }
  }
  // @objc
     func clientChose() {
        switch self.listeningText.lowercased()
        {
        case "one","1","وأن" :
            self.ListNote()
           break
        case "two","2","to" :
        //    self.isAddingNote = true
           // self.addNote()
            break
        case "three","3" :
       //     self.deleteNote()
            break
        case "four","4" :
      //      self.updateNote()
            break
        default:
            
            self.synth.speak(AVSpeechUtterance(string: "Sorry I Cann't Know What Do you Say."))
          
          break
            
        }
    }
   
    func ListNote() {
        
        while (x < self.control.notes.count) {
            self.textToSpeak = "note number \(self.control.notes[x].number) is \(self.control.notes[x].text)"
            self.synth.speak(AVSpeechUtterance(string: self.textToSpeak))
            x += 1
        }
//        for note in self.control.notes
//        {
//
//                self.textToSpeak = "note number \(note.number) is \(note.text)"
//                self.synth.speak(AVSpeechUtterance(string: self.textToSpeak))
//
//        }
        
         
       
       
        
    }
  //
    
//    func addNote()
//    {
//        self.synth.speak(AVSpeechUtterance(string: "Say Your Node ."))
//
//        handleStartRecording()
//
//
//    }
//
//  func deleteNote()
//    {
//
//    }
//  func updateNote()
//    {
//
//    }
  
  
    
  
}
