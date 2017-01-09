//
//  StarFormatter.swift
//  Project16
//
//  Created by Stuart Terrett on 1/9/17.
//  Copyright © 2017 Stuart Terrett. All rights reserved.
//

import Cocoa

class StarFormatter: Formatter {
    override func string(for obj: Any?) -> String {
        return obj.map() {
                return String(describing: $0)
            }.flatMap() {
                Int($0)
            }.map() {
                return String(repeating: "⭐️", count: $0)
            } ?? ""
    }
}
