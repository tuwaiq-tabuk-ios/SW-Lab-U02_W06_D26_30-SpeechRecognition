

import UIKit
import AVFoundation

class MainViewController: UIViewController {
  
  var player: AVAudioPlayer?
  
  @IBOutlet weak var startTourButton: UIButton!
  
  override func viewDidLoad() {
    playOpeningMessageSound()
  }

  
  @IBAction func startTourButtonPressed(_ sender: UIButton) {
    stopOpeningMessageSound()
  }
  
  
  func playOpeningMessageSound() {
    guard let url = Bundle.main.url(forResource: "OpeningMessage",
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
  
  func stopOpeningMessageSound() {
    player?.stop()
  }
  
}
