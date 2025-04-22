//
//  MelometerWidget.swift
//  MelometerWidget
//
//  Created by 양승완 on 4/22/25.
//

import WidgetKit
import SwiftUI

func convertDate(date: Date) -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd (E)" // 원하는 형식
    let result = formatter.string(from: date)
    return result
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, startDate: convertDate(date: .now), couplesName: "김유미", dDay: 222)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: .now, startDate: convertDate(date: .now), couplesName: "김유미",  dDay: 222)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ())  {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: .now, startDate: convertDate(date: .now), couplesName: "김유미",  dDay: 222)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
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
    SimpleEntry(date: .now, startDate: convertDate(date: .now), couplesName: "김유미", dDay: 222)
    
}
