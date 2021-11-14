//
//  Controller.swift
//  Note
//
//  Created by Ressam Al-Thebailah on 05/04/1443 AH.
//

import Foundation
class Controller {
    var notes :[Note] = []
  
 
    init()
    {
        notes.append(Note(number: 1, text: "Learning on the braille board"))
        notes.append(Note(number: 2, text: "Memorize the multiplication table for numbers five and seven"))
      notes.append(Note(number: 3, text: "Listen to a text that reads the benefits of charity"))
    }
      
  
  
    
  
    func addNote(note : Note )
    {
        notes.append(note)
    }
  
  
    func  deleteNote(noteNumber num : Int)
    {
        var x = 0
        
        while x < notes.count
        {
            if notes[x].number == num
            {
                notes.remove(at: x)
                break
            }
            x += 1
        }
    }
  
    
    func  updateNote(noteNumber num : Int , noteText : String)
    {
        var x = 0
        
        while x < notes.count
        {
            if notes[x].number == num
            {
                notes[x].text = noteText
                break
            }
            x += 1
        }
    }
    
  func getNote(noteNumber num : Int ) -> String
    {
        var x = 0
        var text : String = ""
        while x < notes.count
        {
            if notes[x].number == num
            {
               text =  notes[x].text
                break
            }
            x += 1
        }
        
        return text
    }
  
    func getLastNoteNumber() -> Int
    {
        if notes.isEmpty
        {
            return -1
        }else
        {
            return notes.last!.number
        }
       
    }
}
