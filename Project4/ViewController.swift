//
//  ViewController.swift
//  Project4
//
//  Created by Todd Fields on 2018-12-09.
//  Copyright © 2018 SKULLGATE Studios. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate, NSGestureRecognizerDelegate {

    // MARK: - Variables
    var rows: NSStackView!
    var selectedWebView: WKWebView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1: Create the stack view and add it to our view
        rows = NSStackView()
        rows.orientation = .vertical
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        
        // 2: Create Auto Layout constraints the pin the stack view to the edges of its container
        rows.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // 3: Create an initial column that contains a single web view
        let column = NSStackView(views: [makeWebView()])
        column.distribution = .fillEqually
        
        // 4: Add this column to the 'rows' stack view
        rows.addArrangedSubview(column)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: - Functions
    func makeWebView() -> NSView {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: "https://www.apple.com")!))
        
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked))
        recognizer.delegate = self
        //recognizer.numberOfClicksRequired = 2
        webView.addGestureRecognizer(recognizer)
        
        if selectedWebView == nil {
            select(webView: webView)
        }
        
        return webView
    }
    
    func select(webView: WKWebView) {
        selectedWebView = webView
        selectedWebView.layer?.borderWidth = 2
        selectedWebView.layer?.borderColor = NSColor.blue.cgColor
    }
    
    @objc func webViewClicked(recognizer: NSClickGestureRecognizer) {
        // get the web view that triggered this method
        guard let newSelectedWebView = recognizer.view as? WKWebView else {
            return
        }
        
        // deselect the currently selected web view
        if let selected = selectedWebView {
            selected.layer?.borderWidth = 0
        }
        
        // select the new one
        select(webView: newSelectedWebView)
    }
    
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        if gestureRecognizer.view == selectedWebView {
            return false
        } else {
            return true
        }
    }

    // MARK: - IBActions
    @IBAction func urlEntered(_ sender: NSTextField) {
        
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        
    }
    
    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // we're adding a new row
            
            // count how many columns that we have so far
            let columnCount = (rows.arrangedSubviews[0] as! NSStackView).arrangedSubviews.count
            
            // make a new array of web views that contain the correct number of columns
            let viewArray = (0 ..< columnCount).map { _ in makeWebView() }
            
            // use that web view array to create a new stack view
            let row = NSStackView(views: viewArray)
            
            // make the stack view size its children equally, then add it to our 'rows' array
            row.distribution = .fillEqually
            rows.addArrangedSubview(row)
        } else {
            // we're deleting a row
            
            // make sure we have at least two rows
            guard rows.arrangedSubviews.count > 1 else { return }
            
            // pull out the final row and make sure that it is a stack view
            guard let rowToremove = rows.arrangedSubviews.last as? NSStackView else { return }
            
            // loop through each web view in the row removing it from the screen
            for cell in rowToremove.arrangedSubviews {
                cell.removeFromSuperview()
            }
            
            // finally, remove the whole stack view row
            rows.removeArrangedSubview(rowToremove)
        }
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // we need to add a column
            for case let row as NSStackView in rows.arrangedSubviews {
                // loop over each row and add a new web view to it
                row.addArrangedSubview(makeWebView())
            }
        } else {
            // we need to delete a column
            
            // pull out the first of our rows
            guard let firstRow = rows.arrangedSubviews.first as? NSStackView else {
                return
            }
            
            // make sure it has at least two columns
            guard firstRow.arrangedSubviews.count > 1 else {
                return
            }
            
            // if we are still here it means it's safe to delete a column
            for case let row as NSStackView in rows.arrangedSubviews {
                // loop over every row
                if let last = row.arrangedSubviews.last {
                    // pull out the last web view in this column and remove it using the two step process
                    row.removeArrangedSubview(last)
                    last.removeFromSuperview()
                }
            }
        }
    }
}

