//
//  DailyAppUsageView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/07/12.
//

import SwiftUI
import DeviceActivity
import FamilyControls

struct DailyAppUsageView: View {
    @State private var selectedDate = Date()
    @State private var authorizationCenter = AuthorizationCenter.shared
    @State private var isAuthorized = false
    @State private var showingAuthorizationAlert = false
    @State private var authorizationError: String?
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header with Date Selection
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("アプリ使用時間")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                
                                Text("1日のアプリ使用状況を確認")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        // Date Picker
                        HStack {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .foregroundStyle(.blue)
                            
                            DatePicker(
                                "日付選択",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            
                            Spacer()
                            
                            Text(dateFormatter.string(from: selectedDate))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .background(Material.regularMaterial)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Content based on authorization status
                    Group {
                        if isAuthorized {
                            // Authorized: Show app usage reports
                            authorizedContentView
                        } else {
                            // Not authorized: Show authorization prompt
                            authorizationPromptView
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                checkAuthorizationStatus()
            }
            .alert("認証エラー", isPresented: $showingAuthorizationAlert) {
                Button("OK") { }
                Button("再試行") {
                    requestAuthorization()
                }
            } message: {
                Text(authorizationError ?? "不明なエラーが発生しました")
            }
        }
    }
    
    // MARK: - Authorized Content
    private var authorizedContentView: some View {
        VStack(spacing: 20) {
            // Today's App Usage Card
            AnalyticsCardView(
                title: "今日のアプリ使用時間",
                icon: "apps.iphone",
                description: "使用時間の多いアプリから表示"
            ) {
                AppUsageReportView(selectedDate: selectedDate)
            }
            
            // Screen Time Summary Card
            AnalyticsCardView(
                title: "スクリーンタイム合計",
                icon: "clock.fill",
                description: "デバイス全体の使用時間"
            ) {
                DailyScreenTimeSummaryView(selectedDate: selectedDate)
            }
        }
    }
    
    // MARK: - Authorization Prompt
    private var authorizationPromptView: some View {
        VStack(spacing: 24) {
            AnalyticsCardView(
                title: "アプリ使用時間の確認",
                icon: "apps.iphone", 
                description: "詳細なアプリ使用時間を確認するには認証が必要です"
            ) {
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    
                    Text("Family Controlsの認証が必要です")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Text("アプリの使用時間を確認するには、iOSのFamily Controls機能へのアクセス許可が必要です。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("認証を開始") {
                        requestAuthorization()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(.vertical)
            }
            
            // Requirements Info Card
            AnalyticsCardView(
                title: "必要な設定",
                icon: "info.circle.fill",
                description: "認証に必要な設定について"
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    RequirementRow(
                        icon: "iphone",
                        title: "実機での実行",
                        description: "シミュレーターでは利用できません"
                    )
                    
                    RequirementRow(
                        icon: "time",
                        title: "スクリーンタイム",
                        description: "設定 → スクリーンタイムを有効にしてください"
                    )
                    
                    RequirementRow(
                        icon: "person.crop.circle",
                        title: "Apple ID",
                        description: "Apple IDでサインインしている必要があります"
                    )
                }
            }
        }
    }
    
    // MARK: - Authorization Methods
    private func checkAuthorizationStatus() {
        isAuthorized = authorizationCenter.authorizationStatus == .approved
    }
    
    private func requestAuthorization() {
        Task {
            do {
                try await authorizationCenter.requestAuthorization(for: .individual)
                await MainActor.run {
                    checkAuthorizationStatus()
                }
            } catch {
                await MainActor.run {
                    authorizationError = "認証に失敗しました: \(error.localizedDescription)"
                    showingAuthorizationAlert = true
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct DailyScreenTimeSummaryView: View {
    let selectedDate: Date
    @State private var filter: DeviceActivityFilter
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let dateInterval = DateInterval(start: startOfDay, end: endOfDay)
        
        self._filter = State(initialValue: DeviceActivityFilter(
            segment: .daily(during: dateInterval),
            users: .all,
            devices: .init([.iPhone, .iPad])
        ))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            DeviceActivityReport(.totalActivity, filter: filter)
                .frame(height: 100)
        }
        .onChange(of: selectedDate) { _, newDate in
            updateFilter(for: newDate)
        }
    }
    
    private func updateFilter(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let dateInterval = DateInterval(start: startOfDay, end: endOfDay)
        
        filter = DeviceActivityFilter(
            segment: .daily(during: dateInterval),
            users: .all,
            devices: .init([.iPhone, .iPad])
        )
    }
}

struct RequirementRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DailyAppUsageView()
}