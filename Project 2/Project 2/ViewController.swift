//
//  ViewController.swift
//  Project 2
//
//  Created by Stuart Terrett on 11/25/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa
import GameplayKit

class ViewController: NSViewController,
    NSTableViewDataSource, NSTableViewDelegate {
    let illegalCharacters = CharacterSet(charactersIn: "0123456789").inverted
    
    var answer = ""
    var guesses = [String]()

    @IBOutlet var tableView: NSTableView!
    @IBOutlet var guess: NSTextField!
    
    @IBAction func submitGuess(_ sender: NSButton) {
        let guessString = guess.stringValue
        guard validateGuess(guessString) else {
            showAlert(alert: "Invalid Guess", message: "Guesses must be four distinct integers")
            return
        }
        
        guesses.append(guessString)
        tableView.insertRows(at: IndexSet(integer: 0), withAnimation: .slideDown)
        
       if guessString == answer {
            showAlert(alert: "Congratulations!", message: "Click OK to play again")
            startGame()
        }
    }
    
    func validateGuess(_ g: String) -> Bool {
        return Set(g.characters).count == 4 &&
            g.rangeOfCharacter(from: illegalCharacters) == nil
    }
    
    func showAlert(alert: String, message: String) {
        let modal = NSAlert()
        modal.messageText = alert
        modal.informativeText = message
        modal.runModal()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startGame()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return guesses.count
    }
    
    func result(for guess: String) -> String {
        let answerArray = Array(answer.characters)
        let guessArray = Array(guess.characters)
        let bulls = zip(guessArray, answerArray).map() {
            $0 == $1
        }.filter() {$0}.count
        
        let contains = guessArray.map() {
            answerArray.contains($0)
            }.filter() {$0}.count
        
        return "\(bulls) bulls and \(contains - bulls) cows"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return  nil }
        
        let guessIdx = guesses.count - row - 1
        if tableColumn?.title == "Guess" {
            vw.textField?.stringValue = guesses[guessIdx]
        } else {
            vw.textField?.stringValue = result(for: guesses[guessIdx])
        }
        
        return vw
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func startGame() {
        clearView()
        answer = createAnswer()
    }
    
    func clearView() {
        guess.stringValue = ""
        guesses.removeAll()
        tableView.reloadData()
    }
    
    func createAnswer() -> String {
        let random = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: Array(0...9)) as! [Int]
        // return random.suffix(4).joined("") Ambiguous reference to member suffix. wtf?
        var ans = ""
        for i in 1...4 {
            ans.append(String(random[i]))
        }
        return ans
    }
}
