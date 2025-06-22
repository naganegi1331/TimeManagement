//
//  DeviceUsageComponents.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/19.
//

import SwiftUI

struct DeviceUsageNavigationButton: View {
    let isAuthorized: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isAuthorized ? "chart.bar.fill" : "lock.fill")
                .font(.title2)
                .foregroundStyle(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isAuthorized ? "詳細なデバイス使用時間を確認" : "デバイス使用時間の認証")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text(isAuthorized ? "全アプリの使用時間とレポートを表示" : "Family Controlsの認証が必要です")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.title2)
                .foregroundStyle(.white)
        }
        .padding(20)
        .background((isAuthorized ? Color.blue : Color.orange).gradient)
        .cornerRadius(16)
        .shadow(color: (isAuthorized ? Color.blue : Color.orange).opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    VStack(spacing: 16) {
        DeviceUsageNavigationButton(isAuthorized: true)
        DeviceUsageNavigationButton(isAuthorized: false)
    }
    .padding()
}