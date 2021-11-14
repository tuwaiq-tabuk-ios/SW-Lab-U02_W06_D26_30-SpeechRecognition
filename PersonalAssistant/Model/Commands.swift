//
//  Commands.swift
//  SpokenWord
//
//  Created by Marzouq Almukhlif on 04/04/1443 AH.
//  Copyright © 1443 Apple. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

//let local = "en-US"

//let PointsOfInterest = NSLocalizedString("Points of Interest", comment: "Points of Interest")
 
enum commandsEnum {
  case hi,fine,safari,photo,messages,settings,search,help,howAreYou,changeName
}

let synthesizer = AVSpeechSynthesizer()


class Commands {
  let tableView: UITableView
//  var theData: [MyMessage]
  var name:String!
  var nameSeted = false
  

  init(tableView:UITableView,thedata:[MyCommandTextModel]) {
    self.tableView = tableView
//    self.theData = thedata
    if UserDefaults.standard.string(forKey: "name") != nil {
      self.name = UserDefaults.standard.string(forKey: "name")
      nameSeted = true

    }
    
    
    
  }
  
  var coloursAndNames: Dictionary<String, UIColor> = {
    return [
            NSLocalizedString("black", comment: "black color"): .black,
            NSLocalizedString("white", comment: "white color"): .white,
            NSLocalizedString("gray", comment: "gray color"): .gray,
            NSLocalizedString("red", comment: "red color"): .red,
            NSLocalizedString("green", comment: "green color"): .green,
            NSLocalizedString("blue", comment: "blue color"): .blue,
            NSLocalizedString("cyan", comment: "cyan color"): .cyan,
            NSLocalizedString("yellow", comment: "yellow color"): .yellow,
            NSLocalizedString("magenta", comment: "magenta color"): .magenta,
            NSLocalizedString("orange", comment: "orange color"): .orange,
            NSLocalizedString("purple", comment: "purple color"): .purple,
            NSLocalizedString("brown", comment: "brown color"): .brown,
            NSLocalizedString("clear", comment: "clear color"): .clear,
           ]
  }()
  
  
  func talkToUser(_ text:String , _ local:String){
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
      self.addMessage(text)
      let utterance = AVSpeechUtterance(string: text)
      utterance.voice = AVSpeechSynthesisVoice(language: local)
      if synthesizer.isSpeaking {
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)

      } else {
        synthesizer.speak(utterance)
      }
    }
  }
  
 func addMessage(_ text:String) {
    let newMessage =  MyCommandTextModel(incoming: true, command: text)
    theData.append(newMessage)
    self.tableView.reloadData()
    self.tableView.scroll(to: .bottom, animated: true)

  }
  
  
   func setName(_ name:String) {
    self.name = name
    nameSeted = true
    
    UserDefaults.standard.setValue(name, forKey: "name")
    let msgName = NSLocalizedString("Your Name is %@,\nI will remember that", comment: "msgName")
    let wantedString = String(format: msgName, name)
    talkToUser(wantedString, local)
  }
  
   func updateViewColor(_ spokenText: String) {
    guard let lastWord = spokenText.components(separatedBy: .whitespaces).last, let colour = coloursAndNames[lastWord] else {
      

      return
    }
    tableView.backgroundColor = colour
  }
  
  
   func commandCall(_ command:commandsEnum) {
    switch command {
    case .hi:
      let msgHi = NSLocalizedString("Hi %@", comment: "msgHi")
      let wantedString = String(format: msgHi, name!)
      self.talkToUser(wantedString, local)
    case .fine:
      let msgFine = NSLocalizedString("I wish you a happy day %@", comment: "msgFine")
      let wantedString = String(format: msgFine, name!)
      self.talkToUser(wantedString, local)
    case .safari:
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
        UIApplication.shared.open(URL(string:"https://google.com/")!)
      }
    case .photo:
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
        UIApplication.shared.open(URL(string:"photos-redirect://")!)
      }
    case .messages:
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
        UIApplication.shared.open(URL(string:"sms:")!)
      }
    case .settings:
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
      }
    case .search:
      let msgSearch = NSLocalizedString("Ok, What do you want to look for?", comment: "msgSearch")
      self.talkToUser(msgSearch, local)
    
    case .help:
      let msgHelp = NSLocalizedString("""
Commands Voice:

Help : To show the commands

Hi : To welcome you

Photo : To open CameraRoll app

Safari : To open Safari app

Messages : To open Messages app

Settings : To open settings app

Search : To open WebKit and search on Google


Colors : Say any color to change the Background Color Of rootView
""", comment: "msgHelp")

      

      
      self.talkToUser(msgHelp,local)
    case .howAreYou:
      let msgHowAreYou = NSLocalizedString("I'm Fine , Thanks %@ for ask me!", comment: "msgHowAreYou")
      let wantedString = String(format: msgHowAreYou, self.name!)

      self.talkToUser(wantedString, local)
    
    case .changeName:
      let msgChangeName = NSLocalizedString("Well, what do you want me to call you?\nPress the mic button and talk", comment: "msgChangeName")
      self.talkToUser(msgChangeName, local)
      nameSeted = false

    }
    
  }
  
}

