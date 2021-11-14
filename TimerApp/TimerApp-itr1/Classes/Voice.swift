

import AVFoundation
import Speech

class Voice {
  
  
    private var utteranceRate: Float = 0.4
     let synthesizer = AVSpeechSynthesizer()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    func read(text input: String) {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        let utterance = AVSpeechUtterance(string: input)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = utteranceRate
      if synthesizer.isSpeaking{
        synthesizer.stopSpeaking(at: .word)
      }else{
        synthesizer.speak(utterance)
      }
    }
  

}
