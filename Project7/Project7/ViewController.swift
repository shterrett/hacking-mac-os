//
//  ViewController.swift
//  Project7
//
//  Created by Stuart Terrett on 12/3/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

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
