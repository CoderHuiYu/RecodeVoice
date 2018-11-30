# RecodeVoice
## Usage

### Swift

1. Ensure your view  controller conforms to the `RecordViewProtocol` protocol:
```swift
class  YourViewController: RecordViewProtocol{
    func endConvertWithData(_ data: NSData) {
        voiceData = data
        // YourViewController code here
    }
}
```
