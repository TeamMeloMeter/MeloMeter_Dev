//
//  MelometerWidget.swift
//  MelometerWidget
//
//  Created by 양승완 on 4/22/25.
//

import WidgetKit
import SwiftUI


func getDayCount(dateString: String) -> Int {
    
    let dateDate = Date.stringToDate(dateString: dateString, type: .yearToDay) ?? Date.now
    
    let currentDate = Date.fromStringOrNow(Date().toString(type: .yearToDay), .yearToDay)
    let sinceDay = ( Calendar.current.dateComponents([.day], from: dateDate, to: currentDate).day ?? 0 ) + 1
    return sinceDay
}

func getEntry() -> SimpleEntry {
    let userDefaults = UserDefaults(suiteName: "group.com.teamMelometer.widget")
    
    let startDate = userDefaults!.string(forKey: "startDate") ?? ""
    let othersName = userDefaults!.string(forKey: "othersName") ?? ""

    let dDay = getDayCount(dateString: startDate)
    
    let entry = SimpleEntry(date: .now, startDate: startDate, couplesName: othersName, dDay: dDay)
    
    return entry
    
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return getEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(getEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let now = Date()
           let calendar = Calendar.current

           var nextUpdate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now)!

           // 이미 자정 지났으면 → 내일 자정으로 설정
           if nextUpdate <= now {
               nextUpdate = calendar.date(byAdding: .day, value: 1, to: nextUpdate)!
           }

           let entry = getEntry()

           let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
           completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    let startDate: String
    let couplesName: String
    let dDay: Int
}

struct MelometerWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            HStack(spacing: 6) {
                Image("DdayIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit).frame(width: 24, height: 24)
                
                VStack(alignment: .leading) {
                    Text(entry.couplesName).font(.system(size: 10))
                    Text("\(entry.startDate)").font(.system(size: 10))
                }
                
                Spacer()
            }.frame(width: .infinity ,height: 40)
 
            Spacer()
            HStack(alignment: .center, spacing: 1) {
                Spacer()
                Text("\(entry.dDay) 일").font(.title)
          
            }
        }
       
    }
}

struct MelometerWidget: Widget {
    let kind: String = "MelometerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MelometerWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MelometerWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    MelometerWidget()
} timeline: {
    getEntry()
    
}
