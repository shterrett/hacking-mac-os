//
//  ViewController.swift
//  Project4
//
//  Created by Stuart Terrett on 11/27/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate, NSGestureRecognizerDelegate {
    var rows: NSStackView!
    var selectedWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rows = NSStackView()
        rows.orientation = .vertical
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        
        rows.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let initialWebView = makeWebView()
        select(webView: initialWebView as! WKWebView)
        let firstRow = NSStackView(views: [initialWebView])
        firstRow.distribution = .fillEqually
        
        rows.addArrangedSubview(firstRow)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func urlEntered(_ sender: NSTextField) {
        guard let selected = selectedWebView else { return }
        if let url = URL(string: sender.stringValue) {
            selected.load(URLRequest(url: url))
        }
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        guard let selected = selectedWebView else { return }
        if sender.selectedSegment == 0 {
            selected.goBack()
        } else {
            selected.goForward()
        }
    }

    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        if add(sender) {
            let columnCount = (rows.arrangedSubviews.first as! NSStackView).arrangedSubviews.count
            let viewArray: [NSView] = (1...columnCount).map() { _ in makeWebView() }
            let newRow = NSStackView(views: viewArray)
            newRow.distribution = .fillEqually
            rows.addArrangedSubview(newRow)
        } else {
            guard rows.arrangedSubviews.count > 1 else { return }
            guard let lastRow = rows.arrangedSubviews.last as? NSStackView else { return }
            for column in lastRow.arrangedSubviews {
                column.removeFromSuperview()
            }
            rows.removeArrangedSubview(lastRow)
            lastRow.removeFromSuperview()
        }
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
        if add(sender) {
            for case let row as NSStackView in rows.arrangedSubviews {
                row.addArrangedSubview(makeWebView())
            }
        } else {
            guard let firstRow = rows.arrangedSubviews.first as? NSStackView else { return }
            guard firstRow.arrangedSubviews.count > 1 else { return }
            for case let row as NSStackView in rows.arrangedSubviews {
                if let last = row.arrangedSubviews.last {
                    row.removeArrangedSubview(last)
                    last.removeFromSuperview()
                }
            }
        }
    }
    
    func add(_ sender: NSSegmentedControl) -> Bool {
        return sender.selectedSegment == 0
    }
    
    func webViewClicked(recognizer: NSClickGestureRecognizer) {
        guard let newView = recognizer.view as? WKWebView else { return }
        if let selected = selectedWebView {
            selected.layer?.borderWidth = 0
        }
        select(webView: newView)
    }
    
    func select(webView: WKWebView) {
        selectedWebView = webView
        selectedWebView.layer?.borderWidth = 4
        selectedWebView.layer?.borderColor = NSColor.blue.cgColor
        
        updateUrlString(selectedWebView)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard webView == selectedWebView else { return }
        
        updateUrlString(webView)
    }
    
    func updateUrlString(_ webView: WKWebView) {
        if let windowController = view.window?.windowController as? WindowController {
            windowController.urlEntry?.stringValue = webView.url?.absoluteString ?? ""
        }
    }
    
    func makeWebView() -> NSView {
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked))
        recognizer.delegate = self
        let view = WKWebView()
        view.navigationDelegate = self
        view.wantsLayer = true
        view.addGestureRecognizer(recognizer)
        view.load(URLRequest(url: URL(string: "https://apple.com")!))
        return view
    }
    
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        return gestureRecognizer.view != selectedWebView
    }
}

