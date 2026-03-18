//
//  RainbowPagerWidgetLiveActivity.swift
//  RainbowPagerWidget
//
//  Created by 정가연 on 2/11/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RainbowPagerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct RainbowPagerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RainbowPagerWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension RainbowPagerWidgetAttributes {
    fileprivate static var preview: RainbowPagerWidgetAttributes {
        RainbowPagerWidgetAttributes(name: "World")
    }
}

extension RainbowPagerWidgetAttributes.ContentState {
    fileprivate static var smiley: RainbowPagerWidgetAttributes.ContentState {
        RainbowPagerWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: RainbowPagerWidgetAttributes.ContentState {
         RainbowPagerWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: RainbowPagerWidgetAttributes.preview) {
   RainbowPagerWidgetLiveActivity()
} contentStates: {
    RainbowPagerWidgetAttributes.ContentState.smiley
    RainbowPagerWidgetAttributes.ContentState.starEyes
}
