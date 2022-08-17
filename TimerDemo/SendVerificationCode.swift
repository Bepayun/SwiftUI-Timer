//
//  ContentView.swift
//  TimerDemo
//
//  Created by apple on 2021/9/29.
//

import SwiftUI
import Combine

extension Notification.Name {
    // 无密登录 验证码发送 通知
    static let sendSuccess = Notification.Name("noPassword-send-success")
}

struct SendVerificationCode: View {
    
    @State var width: CGFloat
    @State var height: CGFloat
    @State var topLeft: Bool
    
    static let DURATION = 60 // 持续时间
    @State var isResend: Bool = false // 用于记录第二次开始显示resend
    
    enum TimerState: Int {
        case send = 0 // 初始状态 发送
        case waiting = 1 // 等待确认发送
        case timer = 2 // 开始倒计时
    }
    
    @State var timerState: TimerState = .send
    
    // 给定时器添加半秒的容忍度
    let timer = Timer.publish(every: 1, on: .main, in: .common) // .autoconnect()
    @State var timerIns: AnyCancellable?
    @State var countDown: Int = SendVerificationCode.DURATION // 倒计时
    @State var startTime: Double = NSDate().timeIntervalSince1970
    
    var action: () -> Bool
    
    var body: some View {
        VStack(spacing: 0) {
            let resend = "Resend"
            let send = "Send"

            let sendText = (isResend ? resend : send)
            
            Text(timerState == .timer ? "\(countDown)" : sendText)
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .font(.system(size: 14).weight(.bold))
                .background(timerState == .send ? Color.ThemeColor : Color.UnselectedThemeColor)
                .cornerRadius(8)
            
                .onTapGesture {
                    // 只有在send状态可以点击
                    guard timerState == .send else { return }
                    
                    if action() { // 开始发送
                        timerState = .waiting
                    }
                }
            
                .onReceive(NotificationCenter.default.publisher(for: .sendSuccess)) { obj in
                    if (obj.userInfo?["success"] as? Bool ?? false) {
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
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    // 程序进入前台
                    // 重启计时器
                    connectTimer()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    // 程序进入后台暂停计时器
                    stopTimer()
                }
                
        }
    }
    
    // MARK: - 启动timer
    private func connectTimer() {
        timerIns?.cancel()
        timerIns = timer.autoconnect().sink { date in
            count()
        }
        // 直接先数一次
        count()
    }
    
    // MARK: - 暂停timer
    private func stopTimer() {
        timerIns?.cancel()
        timerIns = nil
    }
    
    private func count() {
        guard timerState == .timer else { return }
        // 计算倒计时
        let currentTime = NSDate().timeIntervalSince1970
        let timeElapsed: Int = Int(currentTime - startTime)
        countDown = SendVerificationCode.DURATION - timeElapsed
        
        if countDown <= 0 {
            // 倒计时结束
            isResend = true
            timerState = .send
            // 暂停计时器
        }
    }
}
