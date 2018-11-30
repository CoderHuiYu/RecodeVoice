# RecodeVoice
## Usage

### Swift

1. Ensure your view  controller conforms to the `ZLRecordButtonProtocol` protocol:
```swift
class  YourViewController: ZLRecordButtonProtocol{
   func recordFinishRecordVoice(didFinishRecode voiceData: NSData) {
        // YourViewController code here
    }
}
```
