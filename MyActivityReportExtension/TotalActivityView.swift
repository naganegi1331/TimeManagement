//
//  TotalActivityView.swift
//  MyActivityReportExtension
//
//  Created by Hiroki Kashihara on 2025/06/22.
//

import SwiftUI

struct TotalActivityView: View {
    let totalActivity: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text("総使用時間")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(totalActivity)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Material.regularMaterial)
        .cornerRadius(12)
    }
}

struct AppUsageView: View {
    let appUsageData: [AppUsageData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("アプリ使用時間")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if appUsageData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("使用時間データがありません")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("アプリの使用を開始すると、ここに使用時間が表示されます")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 40)
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(appUsageData.indices, id: \.self) { index in
                            AppUsageRow(
                                appData: appUsageData[index],
                                rank: index + 1
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Material.regularMaterial)
        .cornerRadius(12)
    }
}

struct AppUsageRow: View {
    let appData: AppUsageData
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // ランキング表示
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(rankColor)
                .clipShape(Circle())
            
            // アプリ情報
            VStack(alignment: .leading, spacing: 4) {
                Text(appData.appName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(appData.bundleIdentifier)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 使用時間
            Text(appData.formattedDuration)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .orange
        case 2: return .blue
        case 3: return .green
        default: return .gray
        }
    }
}

// In order to support previews for your extension's custom views, make sure its source files are
// members of your app's Xcode target as well as members of your extension's target. You can use
// Xcode's File Inspector to modify a file's Target Membership.
#Preview("Total Activity") {
    TotalActivityView(totalActivity: "1h 23m")
}

#Preview("App Usage - With Data") {
    AppUsageView(appUsageData: [
        AppUsageData(appName: "Safari", bundleIdentifier: "com.apple.mobilesafari", totalDuration: 3600, formattedDuration: "1h"),
        AppUsageData(appName: "Messages", bundleIdentifier: "com.apple.MobileSMS", totalDuration: 1800, formattedDuration: "30m"),
        AppUsageData(appName: "Settings", bundleIdentifier: "com.apple.Preferences", totalDuration: 900, formattedDuration: "15m")
    ])
}

#Preview("App Usage - Empty") {
    AppUsageView(appUsageData: [])
}
