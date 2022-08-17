//
//  ContentView.swift
//  TimerDemo
//
//  Created by apple on 2021/9/29.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Timer demo")
            
            Spacer().frame(height: 20)
            
            SendVerificationCode(width: 90, height: 48, topLeft: true, action: {
                // 操作信息
                // 测试通知
                NotificationCenter.default.post(name: .sendSuccess, object: nil, userInfo: ["success": true])
                return true
            })
            Spacer()
        }
    }
}
