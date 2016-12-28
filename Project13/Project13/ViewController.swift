//
//  ViewController.swift
//  Project13
//
//  Created by Stuart Terrett on 12/24/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet var imageView: NSImageView!


    @IBOutlet var caption: NSTextView!
    @IBOutlet var fontName: NSPopUpButton!
    @IBOutlet var fontSize: NSPopUpButton!
    @IBOutlet var fontColor: NSColorWell!

    @IBOutlet var backgroundImage: NSPopUpButton!
    @IBOutlet var backgroundColorStart: NSColorWell!
    @IBOutlet var backgroundColorEnd: NSColorWell!

    @IBOutlet var dropShadowStrength: NSSegmentedControl!
    @IBOutlet var dropShadowTarget: NSSegmentedControl!

    var screenshotImage: NSImage?

    var document: Document {
        let oughtToBeDocument = view.window?.windowController?.document as? Document
        assert(oughtToBeDocument != nil, "Unable to find document")
        return oughtToBeDocument!
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        generatePreview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFonts()
        loadBackgroundImages()
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(importScreenshot))
        imageView.addGestureRecognizer(recognizer)

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func generatePreview() {
        let image = NSImage(size: CGSize(width: 1242, height: 2208), flipped: false) { [unowned self] rect -> Bool in
            guard let ctx = NSGraphicsContext.current()?.cgContext else { return false }

            self.clearBackground(context: ctx, rect: rect)
            self.drawBackgroundImage(rect: rect)
            self.drawOverlay(rect: rect)
            let captionOffset = self.drawCaption(context: ctx, rect: rect)
            self.drawDevice(context: ctx, rect: rect, captionOffset: captionOffset)
            self.drawScreenshot(context: ctx, rect: rect, captionOffset: captionOffset)
            return true
        }

        imageView.image = image
    }

    func clearBackground(context: CGContext, rect: CGRect) {
        context.setFillColor(NSColor.white.cgColor)
        context.fill(rect)
    }

    func drawBackgroundImage(rect: CGRect) {
        if backgroundImage.selectedTag() == 999 { return }
        guard let title = backgroundImage.titleOfSelectedItem else { return }
        guard let image = NSImage(named: title) else { return }

        image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
    }

    func drawOverlay(rect: CGRect) {
        let gradient = NSGradient(starting: backgroundColorStart.color, ending: backgroundColorEnd.color)
        gradient?.draw(in: rect, angle: -90)
    }

    func drawCaption(context: CGContext, rect: CGRect) -> CGFloat {
        if dropShadowStrength.selectedSegment != 0 {
            if [0, 1].contains(dropShadowTarget.selectedSegment) {
                setShadow()
            }
        }

        let string = caption.textStorage?.string ?? ""
        let insetRect = rect.insetBy(dx: 40, dy: 20)
        let attributedString = NSAttributedString(string: string, attributes: createCaptionAttributes())
        attributedString.draw(in: insetRect)

        if dropShadowStrength.selectedSegment == 2 {
            if [0, 1].contains(dropShadowTarget.selectedSegment) {
                attributedString.draw(in: insetRect)
            }
        }
        clearShadow()

        let availableSpace = CGSize(width: insetRect.width, height: CGFloat.greatestFiniteMagnitude)
        let textFrame = attributedString.boundingRect(with: availableSpace, options: [.usesLineFragmentOrigin, .usesFontLeading])
        return textFrame.height
    }

    func createCaptionAttributes() -> [String: Any]? {
        let ps = NSMutableParagraphStyle()
        ps.alignment = .center
        let baseFontSize = fontSize.selectedTag() * 8 + 48
        let selectedFontName = fontName.selectedItem?.title.trimmingCharacters(in: .whitespacesAndNewlines) ?? "HelveticaNeue-Medium"
        guard let font = NSFont(name: selectedFontName, size: CGFloat(baseFontSize)) else { return nil }
        let color = fontColor.color
        return [NSParagraphStyleAttributeName: ps,
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: color
        ]

    }

    func drawDevice(context: CGContext, rect: CGRect, captionOffset: CGFloat) {
        let image = #imageLiteral(resourceName: "iPhone")
        let offsetX = (rect.size.width - image.size.width) / 2
        let offsetY = (rect.size.height - image.size.height) / 2 - captionOffset

        if dropShadowStrength.selectedSegment != 0 {
            if [0, 2].contains(dropShadowTarget.selectedSegment) {
                setShadow()
            }
        }

        image.draw(at: CGPoint(x: offsetX, y: offsetY), from: .zero, operation: .sourceOver, fraction: 1)

        if dropShadowStrength.selectedSegment == 2 {
            if [0, 2].contains(dropShadowTarget.selectedSegment) {
                image.draw(at: CGPoint(x: offsetX, y: offsetY), from: .zero, operation: .sourceOver, fraction: 1)
            }
        }

        clearShadow()
    }

    func drawScreenshot(context: CGContext, rect: CGRect, captionOffset: CGFloat) {
        guard let screenshot = screenshotImage else { return }
        screenshot.size = CGSize(width: 891, height: 1584)

        let offsetY = 314 - captionOffset
        screenshot.draw(at: CGPoint(x: 176, y: offsetY), from: .zero, operation: .sourceOver, fraction: 1)
    }

    func setShadow() {
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize.zero
        shadow.shadowColor = NSColor.black
        shadow.shadowBlurRadius = 50
        shadow.set()
    }

    func clearShadow() {
        let shadow = NSShadow()
        shadow.set()
    }

    @IBAction func export(_ sender: Any) {
        guard let image = (imageView.image.flatMap() {
            $0.tiffRepresentation
        }.flatMap() {
                NSBitmapImageRep(data: $0)
        }.flatMap() {
            $0.representation(using: .PNG, properties: [:])
        }) else { return }

        let panel = NSSavePanel()
        panel.allowedFileTypes = ["png", "jpg"]

        panel.begin { result in
            if result == NSFileHandlingPanelOKButton {
                guard let url = panel.url else { return }

                do {
                    try image.write(to: url)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    @IBAction func changeFontSize(_ sender: NSMenuItem) {
        updateDocument()
        generatePreview()
    }

    @IBAction func changeFontColor(_ sender: NSColorWell) {
        updateDocument()
        generatePreview()
    }

    @IBAction func changeBackgroundImage(_ sender: NSMenuItem) {
        updateDocument()
        generatePreview()
    }

    @IBAction func changeBackgroundColorStart(_ sender: NSColorWell) {
        updateDocument()
        generatePreview()
    }

    @IBAction func changeBackgroundColorEnd(_ sender: NSColorWell) {
        updateDocument()
        generatePreview()
    }

    @IBAction func changeDropShadowStrength(_ sender: NSSegmentedControl) {
        updateDocument()
        generatePreview()
    }

    @IBAction func changeDropShadowTarget(_ sender: NSSegmentedControl) {
        updateDocument()
        generatePreview()
    }

    func changeFontName(_ sender: NSMenuItem) {
        updateDocument()
        generatePreview()
    }

    func textDidChange(_ notification: Notification) {
        updateDocument()
        generatePreview()
    }

    func importScreenshot() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["jpg", "png"]

        panel.begin { [unowned self] result in
            if result == NSFileHandlingPanelOKButton {
                self.screenshotImage = panel.url.flatMap() {
                    NSImage(contentsOf: $0)
                }
                self.generatePreview()
            }
        }
    }

    func loadFonts() {
        guard let fontFile = Bundle.main.url(forResource: "fonts", withExtension: nil) else { return }
        guard let fonts = try? String(contentsOf: fontFile) else { return }
        let fontNames = fonts.components(separatedBy: "\n")

        for font in fontNames {
            if font.hasPrefix(" ") {
                let item = NSMenuItem(title: font, action: #selector(changeFontName), keyEquivalent: "")
                item.target = self
                fontName.menu?.addItem(item)
            } else {
                let item = NSMenuItem(title: font, action: nil, keyEquivalent: "")
                item.target = self
                item.isEnabled = false
                fontName.menu?.addItem(item)
            }
        }

        fontName.selectItem(withTitle: " HelveticaNeue-Medium")
    }

    func loadBackgroundImages() {
        let allImages = ["Antique Wood", "Autumn Leaves", "Autumn Sunset", "Autumn by the Lake", "Beach and Palm Tree",
                         "Blue Skies", "Bokeh (Blue)", "Bokeh (Golden)", "Bokeh (Green)",
                         "Bokeh (Orange)", "Bokeh (Rainbow)", "Bokeh (White)", "Burning Fire",
                         "Cherry Blossom", "Coffee Beans", "Cracked Earth",
                         "Geometric Pattern 1", "Geometric Pattern 2", "Geometric Pattern 3",
                         "Geometric Pattern 4", "Grass", "Halloween", "In the Forest",
                         "Jute Pattern", "Polka Dots (Purple)", "Polka Dots (Teal)", "Red Bricks",
                         "Red Hearts", "Red Rose", "Sandy Beach", "Sheet Music", "Snowy Mountain",
                         "Spruce Tree Needles", "Summer Fruits", "Swimming Pool", "Tree Silhouette",
                         "Tulip Field", "Vintage Floral", "Zebra Stripes"]

        for image in allImages {
            let item = NSMenuItem(title: image, action: #selector(changeBackgroundImage), keyEquivalent: "")
            item.target = self
            backgroundImage.menu?.addItem(item)
        }
    }

    func updateDocument() {
        document.screenshot.caption = caption.string ?? ""
        document.screenshot.captionFontName = fontName.titleOfSelectedItem ?? ""
        document.screenshot.captionFontSize = fontSize.tag
        document.screenshot.captionColor = fontColor.color

        if backgroundImage.selectedTag() == 999 {
            document.screenshot.backgroundImage = ""
        } else {
            document.screenshot.backgroundImage = backgroundImage.titleOfSelectedItem ?? ""
        }
        document.screenshot.backgroundColorStart = backgroundColorStart.color
        document.screenshot.backgroundColorEnd = backgroundColorEnd.color

        document.screenshot.dropShadowTarget = dropShadowTarget.selectedSegment
        document.screenshot.dropShadowStrength = dropShadowStrength.selectedSegment
    }

    func updateUIFromDocument() {
        caption.string = document.screenshot.caption
        fontName.selectItem(withTitle: document.screenshot.captionFontName)
        fontSize.selectItem(withTag: document.screenshot.captionFontSize)
        fontColor.color = document.screenshot.captionColor

        if !document.screenshot.backgroundImage.isEmpty {
            backgroundImage.selectItem(withTitle: document.screenshot.backgroundImage)
        }

        backgroundColorStart.color = document.screenshot.backgroundColorStart
        backgroundColorEnd.color = document.screenshot.backgroundColorEnd

        dropShadowTarget.selectSegment(withTag: document.screenshot.dropShadowTarget)
        dropShadowStrength.selectSegment(withTag: document.screenshot.dropShadowStrength)
    }
}
