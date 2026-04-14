import Foundation

@objc(DoubleArrayTransformer)
final class DoubleArrayTransformer: ValueTransformer {
  override class func allowsReverseTransformation() -> Bool { true }

  override class func transformedValueClass() -> AnyClass { NSData.self }

  override func transformedValue(_ value: Any?) -> Any? {
    guard let array = value as? [Double] else { return nil }
    return try? NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: true)
  }

  override func reverseTransformedValue(_ data: Any?) -> Any? {
    guard let data = data as? Data else { return nil }
    do {
      let arr = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSNumber.self], from: data)
      return arr as? [Double]
    } catch {
      print("Transformer decode error:", error)
      return nil
    }
  }
}
