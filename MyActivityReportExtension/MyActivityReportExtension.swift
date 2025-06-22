//
//  MyActivityReportExtension.swift
//  MyActivityReportExtension
//
//  Created by Hiroki Kashihara on 2025/06/22.
//

import DeviceActivity
import SwiftUI

@main
struct MyActivityReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        
        AppUsageReport { appUsageData in
            AppUsageView(appUsageData: appUsageData)
        }
        // Add more reports here...
    }
}
