import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct PagerEntry: TimelineEntry {
    let date: Date
    let isBlinkOn: Bool
    let displayMode: DisplayMode
    let ddayText: String
    let widgetTitle: String
    let widgetIconName: String?
}

// MARK: - Timeline Provider

struct PagerTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> PagerEntry {
        PagerEntry(date: .now, isBlinkOn: true, displayMode: .rainbow, ddayText: "D-365", widgetTitle: "RAINBOW", widgetIconName: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (PagerEntry) -> Void) {
        completion(PagerEntry(date: .now, isBlinkOn: true, displayMode: .rainbow, ddayText: "D-365", widgetTitle: "RAINBOW", widgetIconName: nil))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PagerEntry>) -> Void) {
        var entries: [PagerEntry] = []
        let now = Date()
        
        let defaults = UserDefaults(suiteName: "group.com.reum.rainbowpager")
        let targetDate = defaults?.object(forKey: "ddayTargetDate") as? Date
        let widgetTitle = defaults?.string(forKey: "ddayTitle") ?? "RAINBOW"
        let widgetIconName = defaults?.string(forKey: "ddayIconName")
        
        let ddayText: String
        if let target = targetDate {
            let days = Calendar.current.dateComponents([.day], from: now, to: target).day ?? 0
            ddayText = days >= 0 ? "D-\(days)" : "D+\(abs(days))"
        } else {
            ddayText = "D-????"
        }

        for cycle in 0..<60 {
            for step in 0..<4 {
                let offset = (cycle * 4 + step) * 1_500_000_000
                let entryDate = Calendar.current.date(byAdding: .nanosecond, value: offset, to: now)!
                let isBlinkOn = step % 2 == 0
                let displayMode: DisplayMode = step < 2 ? .rainbow : .dday
                
                entries.append(PagerEntry(
                    date: entryDate,
                    isBlinkOn: isBlinkOn,
                    displayMode: displayMode,
                    ddayText: ddayText,
                    widgetTitle: widgetTitle,
                    widgetIconName: widgetIconName
                ))
            }
        }

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: now)!
        completion(Timeline(entries: entries, policy: .after(nextUpdate)))
    }
}

// MARK: - Widget View

struct RainbowPagerWidgetEntryView: View {
    var entry: PagerEntry

    var body: some View {
        PagerDisplayView(
            isBlinkOn: entry.isBlinkOn,
            displayMode: entry.displayMode,
            ddayText: entry.ddayText,
            widgetTitle: entry.widgetTitle,
            widgetIconName: entry.widgetIconName
        )
    }
}

// MARK: - Widget Configuration

struct RainbowPagerWidget: Widget {
    let kind: String = "RainbowPagerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PagerTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                RainbowPagerWidgetEntryView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                RainbowPagerWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("📟 Rainbow Pager")
        .description("삐삐 LCD 스타일 위젯")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Preview

#Preview("Rectangular", as: .accessoryRectangular) {
    RainbowPagerWidget()
} timeline: {
    PagerEntry(date: .now, isBlinkOn: true, displayMode: .rainbow, ddayText: "D-365", widgetTitle: "RAINBOW", widgetIconName: nil)
    PagerEntry(date: .now, isBlinkOn: false, displayMode: .dday, ddayText: "D-365", widgetTitle: "RAINBOW", widgetIconName: nil)
}
