

import Foundation
import Speech

struct Commands {
  
  let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
  var player: AVAudioPlayer?
  
  func talkToUser(_ text:String , _ local:String){
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: local)
    let synthesizer = AVSpeechSynthesizer()
    if synthesizer.isSpeaking {
      synthesizer.speak(utterance)
 
    } else {
      synthesizer.speak(utterance)
    }
  }
  
  //  MARK - function to user con talk with app
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
}
