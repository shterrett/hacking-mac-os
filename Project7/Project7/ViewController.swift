//
//  ViewController.swift
//  Project7
//
//  Created by Stuart Terrett on 12/3/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {

    @IBOutlet var collectionView: NSCollectionView!
    
    lazy var photosDirectory: URL = {
        let fm = FileManager.default
        let paths = fm.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        let saveDirectory = documentsDirectory.appendingPathComponent("SlideMark")
        
        if !fm.fileExists(atPath: saveDirectory.path) {
            try? fm.createDirectory(at: saveDirectory, withIntermediateDirectories: true)
        }
        
        return saveDirectory
    }()
    
    var photos = [URL]()
    var itemsBeingDragged: Set<IndexPath>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(forDraggedTypes: [kUTTypeURL as String])

        do {
            let fm = FileManager.default
            let files = try fm.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil)
            
            files.filter() {
                ["jpg", "png"].contains($0.pathExtension)
            }.forEach() { photos.append($0) }
        } catch {
            print("Set up error")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func keyUp(with event: NSEvent) {
        guard collectionView.selectionIndexPaths.count > 0 else { return }
        
        if event.charactersIgnoringModifiers == UnicodeScalar(NSDeleteCharacter).map() { String(describing: $0) } {
            let fm = FileManager.default
            for indexPath in collectionView.selectionIndexPaths.reversed() {
                do {
                    try fm.trashItem(at: photos[indexPath.item], resultingItemURL: nil)
                    photos.remove(at: indexPath.item)
                } catch {
                    print("failed to delete \(photos[indexPath.item])")
                }
            }
            
            collectionView.animator().deleteItems(at: collectionView.selectionIndexPaths)
        }
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "Photo", for: indexPath)
        guard let photoItem = item as? Photo else { return item }
        let image = NSImage(contentsOf: photos[indexPath.item])
        photoItem.imageView?.image = image
        
        return photoItem
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        validateDrop draggingInfo: NSDraggingInfo,
                        proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
                        dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>
                        ) -> NSDragOperation {
        return .move
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        draggingSession session: NSDraggingSession,
                        willBeginAt screenPoint: NSPoint,
                        forItemsAt indexPaths: Set<IndexPath>
        ) {
        itemsBeingDragged = indexPaths
    }
    
    private func collectionView(_ collectionView: NSCollectionView,
                        draggingSession session: NSDraggingSession,
                        endedAt screenPoint: NSPoint,
                        forItemsAt indexPaths: Set<IndexPath>
        ) {
        itemsBeingDragged = nil
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        return photos[indexPath.item] as NSPasteboardWriting?
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        acceptDrop draggingInfo: NSDraggingInfo,
                        indexPath: IndexPath,
                        dropOperation: NSCollectionViewDropOperation) -> Bool {
        if let movedItems = itemsBeingDragged?.sorted() {
            performInternalDrag(with: movedItems, to: indexPath)
        } else {
            let pasteboard = draggingInfo.draggingPasteboard()
            guard let items = pasteboard.pasteboardItems else { return true }
            performExternalDrag(with: items, to: indexPath)
        }
        
        return true
    }
    
    func performInternalDrag(with items: [IndexPath], to indexPath: IndexPath) {
        var targetIndex = indexPath.item
        for fromIndexPath in items {
            let fromItemIndex = fromIndexPath.item
            if (fromItemIndex > targetIndex) {
                photos.moveItem(from: fromItemIndex, to: targetIndex)
                collectionView.moveItem(at: IndexPath(item: fromItemIndex, section: 0),
                                        to: IndexPath(item: targetIndex, section: 0))
                targetIndex += 1
            }
        }
        
        targetIndex -= 1
        
        for fromIndexPath in items.reversed() {
            let fromItemIndex = fromIndexPath.item
            if (fromItemIndex < targetIndex) {
                photos.moveItem(from: fromItemIndex, to: targetIndex)
                collectionView.moveItem(at: IndexPath(item: fromItemIndex, section: 0),
                                        to: IndexPath(item: targetIndex, section: 0))
                targetIndex -= 1
            }
        }
    }
    
    func performExternalDrag(with items: [NSPasteboardItem], to indexPath: IndexPath) {
        let sourceUrls = items.map() { (item: NSPasteboardItem) -> URL? in
            item.string(forType: kUTTypeFileURL as String)
                .flatMap() { URL(string: $0) }
            }.flatMap() { $0 }
        
        let fm = FileManager.default
        sourceUrls.forEach() { (source: URL) -> Void in
            let destination = photosDirectory.appendingPathComponent(source.lastPathComponent)
            
            do {
                try fm.copyItem(at: source, to: destination)
            } catch {
                print("Could not copy \(source)")
            }
            
            photos.insert(destination, at: indexPath.item)
            collectionView.insertItems(at: [indexPath])
        }
    }
    
    @IBAction func runExport(_ sender: NSMenuItem) {
        let size: CGSize
        
        if sender.tag == 720 {
            size = CGSize(width: 1280, height: 720)
        } else {
            size = CGSize(width: 1920, height: 1080)
        }
        
        do {
            try exportMovie(at: size)
        } catch {
            print("Whoops")
        }
    }
    
    func exportMovie(at size: NSSize) throws {
        let videoDuration = 8.0
        let timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(videoDuration, 600))
        let savePath = photosDirectory.appendingPathComponent("video.mp4")
        let fm = FileManager.default
        
        if fm.fileExists(atPath: savePath.path) {
            try fm.removeItem(at: savePath)
        }
        
        let mutableComposition = AVMutableComposition()
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = size
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        parentLayer.addSublayer(createVideoLayer(in: parentLayer, composition: mutableComposition, videoComposition: videoComposition, timeRange: timeRange))
        parentLayer.addSublayer(createSlideshow(frame: parentLayer.frame, duration: videoDuration))
        parentLayer.addSublayer(createText(frame: parentLayer.frame))
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = timeRange
        videoComposition.instructions = [instruction]
        
        let exportSession = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality)!
        
        exportSession.outputURL = savePath
        exportSession.videoComposition = videoComposition
        exportSession.outputFileType = AVFileTypeMPEG4
        
        exportSession.exportAsynchronously { [unowned self] in
            DispatchQueue.main.async {
                self.exportFinished(error: exportSession.error)
            }
        }
    }
    
    func createVideoLayer(in parentLayer: CALayer,
                          composition: AVMutableComposition,
                          videoComposition: AVMutableVideoComposition,
                          timeRange: CMTimeRange) -> CALayer {
        let videoLayer = CALayer()
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        let mutableCompositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let trackUrl = Bundle.main.url(forResource: "black", withExtension: "mp4")!
        let asset = AVAsset(url: trackUrl)
        let track = asset.tracks[0]
        
        try! mutableCompositionVideoTrack.insertTimeRange(timeRange, of: track, at: kCMTimeZero)
        
        return videoLayer
    }
    
    func createSlideshow(frame: CGRect, duration: CFTimeInterval) -> CALayer {
        let imageLayer = CALayer()
        imageLayer.bounds = frame
        imageLayer.position = CGPoint(x: imageLayer.bounds.midX, y: imageLayer.bounds.midY)
        imageLayer.contentsGravity = kCAGravityResizeAspectFill
        let fadeAnim = CAKeyframeAnimation(keyPath: "contents")
        fadeAnim.duration = duration
        fadeAnim.isRemovedOnCompletion = false
        fadeAnim.beginTime = AVCoreAnimationBeginTimeAtZero
        
        var values = [NSImage]()
        photos.forEach() {
            if let image = NSImage(contentsOfFile: $0.path) {
                values.append(image)
                values.append(image)
            }
        }
        fadeAnim.values = values
        
        imageLayer.add(fadeAnim, forKey: nil)
        
        return imageLayer
    }
    
    func createText(frame: CGRect) -> CALayer {
        let attrs = [NSFontAttributeName: NSFont.boldSystemFont(ofSize: 24),
                     NSForegroundColorAttributeName: NSColor.green]
        let text = NSAttributedString(string: "Copyright © 2016 Hacking with Swift", attributes: attrs)
        let textSize = text.size()
        let textLayer = CATextLayer();
        textLayer.bounds = CGRect(origin: CGPoint.zero, size: textSize)
        textLayer.anchorPoint = CGPoint(x: 1, y: 1)
        textLayer.position = CGPoint(x: frame.maxX - 10, y: textSize.height + 10)
        textLayer.string = text
        textLayer.display()
        return textLayer
    }
    
    func exportFinished(error: Error?) {
        let alert = NSAlert()
        alert.messageText = error.map() {
            "Error: \($0.localizedDescription)"
        } ?? "Success"
        alert.runModal()
    }
}

extension Array {
    mutating func moveItem(from: Int, to: Int) {
        let item = self[from]
        self.remove(at: from)
        
        if to <= from {
            self.insert(item, at: to)
        } else {
            self.insert(item, at: to - 1)
        }
    }
}
