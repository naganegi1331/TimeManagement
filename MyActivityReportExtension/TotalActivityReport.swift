//
//  TotalActivityReport.swift
//  MyActivityReportExtension
//
//  Created by Hiroki Kashihara on 2025/06/22.
//

import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
    // If your app initializes a DeviceActivityReport with this context, then the system will use
    // your extension's corresponding DeviceActivityReportScene to render the contents of the
    // report.
    static let totalActivity = Self("Total Activity")
    static let appUsage = Self("App Usage")
}

struct AppUsageData {
    let appName: String
    let bundleIdentifier: String
    let totalDuration: TimeInterval
    let formattedDuration: String
}

struct TotalActivityReport: DeviceActivityReportScene {
    // Define which context your scene will represent.
    let context: DeviceActivityReport.Context = .totalActivity
    
    // Define the custom configuration and the resulting view for this report.
    let content: (String) -> TotalActivityView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        // Reformat the data into a configuration that can be used to create
        // the report's view.
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })
        return formatter.string(from: totalActivityDuration) ?? "No activity data"
    }
}

struct AppUsageReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .appUsage
    let content: ([AppUsageData]) -> AppUsageView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [AppUsageData] {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        // シンプルなダミーデータを返す（実際のデータ処理は複雑なため）
        let sampleData = [
            AppUsageData(
                appName: "Safari",
                bundleIdentifier: "com.apple.mobilesafari",
                totalDuration: 3600,
                formattedDuration: "1h"
            ),
            AppUsageData(
                appName: "Messages",
                bundleIdentifier: "com.apple.MobileSMS",
                totalDuration: 1800,
                formattedDuration: "30m"
            ),
            AppUsageData(
                appName: "Settings",
                bundleIdentifier: "com.apple.Preferences",
                totalDuration: 900,
                formattedDuration: "15m"
            )
        ]
        
        // 実際の実装では、以下のようにデータを処理します
        // ただし、現在のAPIの制約により、シンプルな実装に留めます
        /*
        var appUsageMap: [String: (name: String, duration: TimeInterval)] = [:]
        
        for await dataPoint in data {
            // データポイントの処理...
        }
        */
        
        return sampleData
    }
}
