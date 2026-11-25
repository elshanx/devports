import AppKit

let canvas: CGFloat = 1024
let tile = CGRect(x: 100, y: 100, width: 824, height: 824)

func color(_ hex: UInt32) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
}

func gradient(_ colors: [UInt32]) -> CGGradient {
    CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors.map(color) as CFArray, locations: nil)!
}

func symbolMask(_ name: String, pointSize: CGFloat) -> (CGImage, CGSize) {
    let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
    let symbol = NSImage(systemSymbolName: name, accessibilityDescription: nil)!.withSymbolConfiguration(config)!
    var rect = CGRect(origin: .zero, size: symbol.size)
    return (symbol.cgImage(forProposedRect: &rect, context: nil, hints: nil)!, symbol.size)
}

func drawMaster() -> CGImage {
    let context = CGContext(data: nil, width: Int(canvas), height: Int(canvas), bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    let shape = CGPath(roundedRect: tile, cornerWidth: 185, cornerHeight: 185, transform: nil)

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: CGColor(gray: 0, alpha: 0.45))
    context.addPath(shape)
    context.setFillColor(color(0x101722))
    context.fillPath()
    context.restoreGState()

    context.saveGState()
    context.addPath(shape)
    context.clip()
    context.drawLinearGradient(gradient([0x243247, 0x0D121A]), start: CGPoint(x: 0, y: tile.maxY),
                               end: CGPoint(x: 0, y: tile.minY), options: [])
    let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                          colors: [color(0x2FBF8A).copy(alpha: 0.38)!, color(0x2FBF8A).copy(alpha: 0)!] as CFArray,
                          locations: nil)!
    context.drawRadialGradient(glow, startCenter: CGPoint(x: 512, y: 540), startRadius: 0,
                               endCenter: CGPoint(x: 512, y: 540), endRadius: 430, options: [])
    context.restoreGState()

    context.saveGState()
    context.addPath(shape)
    context.setStrokeColor(CGColor(gray: 1, alpha: 0.12))
    context.setLineWidth(4)
    context.strokePath()
    context.restoreGState()

    let (mask, size) = symbolMask("network", pointSize: 430)
    let symbolRect = CGRect(x: (canvas - size.width) / 2, y: (canvas - size.height) / 2 + 20,
                            width: size.width, height: size.height)
    context.saveGState()
    context.clip(to: symbolRect, mask: mask)
    context.drawLinearGradient(gradient([0x6EF0A8, 0x22C3B5]), start: CGPoint(x: 0, y: symbolRect.maxY),
                               end: CGPoint(x: 0, y: symbolRect.minY), options: [])
    context.restoreGState()

    let dot = CGRect(x: 640, y: 236, width: 150, height: 150)
    context.setFillColor(color(0x0D121A))
    context.fillEllipse(in: dot.insetBy(dx: -18, dy: -18))
    context.setFillColor(color(0x4ADE80))
    context.fillEllipse(in: dot)
    return context.makeImage()!
}

func writePNG(_ image: CGImage, size: Int, to url: URL) {
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.interpolationQuality = .high
    context.draw(image, in: CGRect(x: 0, y: 0, width: size, height: size))
    let data = NSBitmapImageRep(cgImage: context.makeImage()!).representation(using: .png, properties: [:])!
    try! data.write(to: url)
}

let iconset = URL(fileURLWithPath: "AppIcon.iconset")
try? FileManager.default.removeItem(at: iconset)
try! FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
let master = drawMaster()
for points in [16, 32, 128, 256, 512] {
    writePNG(master, size: points, to: iconset.appendingPathComponent("icon_\(points)x\(points).png"))
    writePNG(master, size: points * 2, to: iconset.appendingPathComponent("icon_\(points)x\(points)@2x.png"))
}
print("Wrote \(iconset.path)")
