import 'package:home_widget/home_widget.dart';
import '../../features/deadlines/data/models/deadline_item.dart';

class WidgetService {
  static const String androidWidgetName = 'DeadlineWidgetProvider';
  static const String iOSWidgetName = 'DeadlineWidget'; // Placeholder if you setup iOS later

  static Future<void> updateWidgetWithDeadlines(List<DeadlineItem> deadlines) async {
    // Top 3 urgent deadlines
    final active = deadlines.where((d) => !d.isCompleted).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    
    final topItems = active.take(3).toList();

    // Reset counts
    await HomeWidget.saveWidgetData<int>('item_count', topItems.length);

    // Save title and time formatted for each
    for (int i = 0; i < topItems.length; i++) {
      final item = topItems[i];
      final index = i + 1; // 1-indexed for Kotlin
      
      await HomeWidget.saveWidgetData<String>('title_$index', item.title);
      
      final days = item.dueDate.toLocal().difference(DateTime.now()).inDays;
      String timeStr;
      if (days < 0) {
        timeStr = 'GEÇTİ';
      } else if (days == 0) {
        timeStr = 'BUGÜN';
      } else if (days == 1) {
        timeStr = 'YARIN';
      } else {
        timeStr = '$days GÜN';
      }
      
      await HomeWidget.saveWidgetData<String>('time_$index', timeStr);
    }

    // Ping the Native Provider to redraw
    await HomeWidget.updateWidget(
      androidName: androidWidgetName,
      iOSName: iOSWidgetName,
    );
  }
}
