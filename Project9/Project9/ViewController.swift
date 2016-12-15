//
//  ViewController.swift
//  Project9
//
//  Created by Stuart Terrett on 12/15/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        runBackgroundCode1()
//        runBackgroundCode2()
//        runBackgroundCode3()
//        runBackgroundCode4()
//        runSynchronousCode()
//        runDelayedCode()
//        runMultiprocessing1()
        runMultiprocessing2(useGCD: true)
        runMultiprocessing2(useGCD: false)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func runBackgroundCode1() {
        performSelector(inBackground: #selector(log), with: "Hello World 1")
        performSelector(onMainThread: #selector(log), with: "Hello World 2", waitUntilDone: false)
        log(message: "Hello World 3")
    }
    
    func runBackgroundCode2() {
        DispatchQueue.global().async { [unowned self] in
            self.log(message: "On Background thread")
            
            DispatchQueue.main.async {
                self.log(message: "On main thread")
            }
            
        }
    }

    func runBackgroundCode3() {
        DispatchQueue.global().async {
            guard let url = URL(string: "https://apple.com") else { return }
            guard let content = try? String(contentsOf: url) else { return }
            print(content)
        }
    }

    func runBackgroundCode4() {
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            self.log(message: "This is high priority")
        }
    }

    func runSynchronousCode() {
        DispatchQueue.global().async {
            print("Background thread 1")
        }

        print("Main thread 1")

        DispatchQueue.global().sync {
            print("Background thread 2")
        }

        print("Main thread 2")
    }

    func runDelayedCode() {
        perform(#selector(log), with: "Hello World 1", afterDelay: 2)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] in
            self.log(message: "Hello World 2")
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.log(message: "Hello World 3")
        }
    }

    func runMultiprocessing1() {
        DispatchQueue.concurrentPerform(iterations: 10) {
            print($0)
        }
    }

    func runMultiprocessing2(useGCD: Bool) {
        func fibonacci(of num: Int) -> Int {
            if num < 2 {
                return num
            } else {
                return fibonacci(of: num - 1) + fibonacci(of: num - 2)
            }
        }

        var array = Array(0..<42)
        let start = CFAbsoluteTimeGetCurrent()

        if useGCD {
            DispatchQueue.concurrentPerform(iterations: array.count) {
                array[$0] = fibonacci(of: $0)
            }
        } else {
            array = array.map(fibonacci)
        }

        let delta = CFAbsoluteTimeGetCurrent() - start
        let gcdString = useGCD ? "with" : "without"
        print("Total elapsed time: \(delta) \(gcdString) concurrent execution")
    }

    func log(message: String) {
        print("Logging message \(message)")
    }

}

