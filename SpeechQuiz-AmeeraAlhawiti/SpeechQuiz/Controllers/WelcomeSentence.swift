//
//  QuestionBank.swift
//  SpeechQuiz
//
//  Created by Ameera BA on 10/11/2021.
//

import Foundation
import Speech


class WelcomeSentence {
  
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
  
  
  let addAnswer = Commands()
  let addQuestion = ViewController()
  
  
  func talkToUserQuestions() {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)){
      self.addAnswer.talkToUser("To start the quiz please click anywhere at the bottom of the screen and say start", "en-US")}
  }
}
