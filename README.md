# SwiftUI-Timer Demo

## 功能
效果图如下：

![2910741-e30bc1ad8197d2ef](https://user-images.githubusercontent.com/18625637/194701558-46dc9b1d-ce3e-4793-811d-33bbb1db8040.gif)

## 使用方法
```swift
SendVerificationCode(width: 90, height: 48, topLeft: true, action: {
  // 操作信息
  // 测试代码
  NotificationCenter.default.post(name: .sendSuccess, object: nil, userInfo: ["success": true])
  return true
})
```

## 实现原理
定时器运作根据状态机来判断什么时候该进行怎样的工作
```swift
enum TimerState: Int {
  case send = 0 // 初始状态 发送
  case waiting = 1 // 等待确认发送
  case timer = 2 // 开始倒计时
}
```

定时器的默认状态设置为.send
```swift
@State var timerState: TimerState = .send
```

创建计时器发布者的代码及相关实例如下所示：
```swift
// 给定时器添加半秒的容忍度
let timer = Timer.publish(every: 1, on: .main, in: .common)  // .autoconnect()
@State var timerIns: AnyCancellable?
@State var countDown: Int = SendVerificationCode.DURATION // 倒计时
@State var startTime: Double = NSDate().timeIntervalSince1970
```

timerIns类型擦除可取消对象，在取消时执行提供的闭包。订阅者实现可以使用这种类型来提供一个“取消令牌”，使调用者可以取消发布者，但不能使用“订阅”对象来请求项目。一个 AnyCancellable 实例在取消初始化时会自动调用 Cancellable/cancel()。
使用给定的取消时间闭包初始化可取消对象。 参数取消：cancel() 方法执行的闭包。如:
```swift
timerIns?.cancel()
```

定时器触发时，要判断是否成功：定时器触发失败，定时器的状态置为.send状态；定时器触发成功要先记录当前时间，定时器状态置为.timer，再启动定时器。
```swift 
.onReceive(NotificationCenter.default.publisher(for: .sendSuccess)) { obj in
   if (obj.userInfo?["success"] as? Bool ?? false)  {
       // 记录当前时间
       startTime = NSDate().timeIntervalSince1970
       // 验证码发送成功
       timerState = .timer
       // 启动timer
       connectTimer()
   } else {
       // 验证码发送失败
       timerState = .send
  }
 }                    
```

这里我们还要判断程序的状态：程序进入前台我们需要重启定时器；程序进入后台我们得暂停定时器。
```swift 
.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
   // 程序进入前台
  // 重启计时器
  connectTimer()
 }
.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
  // 程序进入后台暂停计时器
  stopTimer()
}
```
