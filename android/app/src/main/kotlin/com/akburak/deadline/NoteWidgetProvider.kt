package com.akburak.deadline

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class NoteWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_note)

            val count = widgetData.getInt("note_count", 0)

            if (count == 0) {
                views.setViewVisibility(R.id.widget_empty_text, View.VISIBLE)
                views.setViewVisibility(R.id.widget_item_1, View.GONE)
                views.setViewVisibility(R.id.widget_item_2, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_empty_text, View.GONE)

                // Note 1
                if (count >= 1) {
                    views.setViewVisibility(R.id.widget_item_1, View.VISIBLE)
                    views.setTextViewText(R.id.widget_title_1, widgetData.getString("note_title_1", ""))
                    views.setTextViewText(R.id.widget_content_1, widgetData.getString("note_content_1", ""))
                } else {
                    views.setViewVisibility(R.id.widget_item_1, View.GONE)
                }

                // Note 2
                if (count >= 2) {
                    views.setViewVisibility(R.id.widget_item_2, View.VISIBLE)
                    views.setTextViewText(R.id.widget_title_2, widgetData.getString("note_title_2", ""))
                    views.setTextViewText(R.id.widget_content_2, widgetData.getString("note_content_2", ""))
                } else {
                    views.setViewVisibility(R.id.widget_item_2, View.GONE)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
