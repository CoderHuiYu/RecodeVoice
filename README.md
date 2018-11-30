# RecodeVoice
## Usage

### Swift
1.you can use the ZLRecordButton on view or controller
```swift
lazy var recordView: ZLRecordButton = {
        let recordView = ZLRecordButton(frame: CGRect(x: 0, y: 530, width: UIScreen.main.bounds.size.width, height: 50))
        recordView.delegate = self
        return recordView
    }()
```
2. Ensure your view  controller conforms to the `ZLRecordButtonProtocol` protocol:
```swift
class  YourViewController: ZLRecordButtonProtocol{
   func recordFinishRecordVoice(didFinishRecode voiceData: NSData) {
        // YourViewController code here
    }
}
```
