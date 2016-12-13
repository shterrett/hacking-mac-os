//
//  GameOverView.swift
//  Project8
//
//  Created by Stuart Terrett on 12/12/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

class GameOverView: NSView {
    
    override func mouseDown(with event: NSEvent) {}
    
    func startEmitting() {
        let title = NSTextField(labelWithString: "Game Over")
        title.font = NSFont.systemFont(ofSize: 96, weight: NSFontWeightHeavy)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = NSColor.white
        addSubview(title)
        
        title.layer?.shadowOffset = CGSize.zero
        title.layer?.shadowOpacity = 1
        title.layer?.shadowRadius = 3
        
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        layer?.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        
        createEmitter()
    }
    
    func createEmitter() {
        let particleEmitter = CAEmitterLayer()
        particleEmitter.emitterPosition = CGPoint(x: frame.midX, y: frame.maxY + 96)
        particleEmitter.emitterShape = kCAEmitterLayerLine
        particleEmitter.emitterSize = CGSize(width: frame.size.width, height: 1)
        particleEmitter.beginTime = CACurrentMediaTime()
        
        particleEmitter.emitterCells = [
            createEmitterCell(color: NSColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)),
            createEmitterCell(color: NSColor(red: 0.3, green: 1, blue: 0.3, alpha: 1)),
            createEmitterCell(color: NSColor(red: 0.2, green: 0.2, blue: 1, alpha: 1)),
            createEmitterCell(color: NSColor(red: 1, green: 1, blue: 0.3, alpha: 1)),
            createEmitterCell(color: NSColor(red: 0.3, green: 1, blue: 1, alpha: 1)),
            createEmitterCell(color: NSColor(red: 1, green: 0.3, blue: 1, alpha: 1)),
            createEmitterCell(color: NSColor(red: 1, green: 1, blue: 1, alpha: 1))
        ]
        
        layer?.addSublayer(particleEmitter)
        
    }
    
    func createEmitterCell(color: NSColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 3
        cell.lifetime = 7
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 200
        cell.velocityRange = 50
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.05
        
        let image = #imageLiteral(resourceName: "particle_confetti")
        if let img = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            cell.contents = img
        }
        
        return cell
    }
}
