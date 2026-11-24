//
//  AnaliticService.swift
//  Tracker
//
//  Created by it on 24.11.2026.
//
import AppMetricaCore
import Foundation
final class AnalyticsService{
    static func report(event: String, item: String? = nil) {
        var parameters: [String: String] = [
            "event": event,
            "screen": "Main"
        ]
        if let item = item {
            parameters["item"] = item
        }
        AppMetrica.reportEvent(
            name: "Main",
            parameters: parameters,
            onFailure: { error in
                print("Ошибка отправки аналитики: \(error)")
            }
        )
    }
}
