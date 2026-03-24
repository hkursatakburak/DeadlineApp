package com.akburak.deadline

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class DeadlineWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            // "R.layout.deadline_mini_widget" is mapped to our updated gothic XML
            val views = RemoteViews(context.packageName, R.layout.deadline_mini_widget)

            val count = widgetData.getInt("item_count", 0)

            if (count == 0) {
                views.setViewVisibility(R.id.widget_empty_text, View.VISIBLE)
                views.setViewVisibility(R.id.widget_item_1, View.GONE)
                views.setViewVisibility(R.id.widget_item_2, View.GONE)
                views.setViewVisibility(R.id.widget_item_3, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_empty_text, View.GONE)
                
                // Row 1
                if (count >= 1) {
                    views.setViewVisibility(R.id.widget_item_1, View.VISIBLE)
                    views.setTextViewText(R.id.widget_title_1, widgetData.getString("title_1", ""))
                    views.setTextViewText(R.id.widget_time_1, widgetData.getString("time_1", ""))
                } else {
                    views.setViewVisibility(R.id.widget_item_1, View.GONE)
                }

                // Row 2
                if (count >= 2) {
                    views.setViewVisibility(R.id.widget_item_2, View.VISIBLE)
                    views.setTextViewText(R.id.widget_title_2, widgetData.getString("title_2", ""))
                    views.setTextViewText(R.id.widget_time_2, widgetData.getString("time_2", ""))
                } else {
                    views.setViewVisibility(R.id.widget_item_2, View.GONE)
                }

                // Row 3
                if (count >= 3) {
                    views.setViewVisibility(R.id.widget_item_3, View.VISIBLE)
                    views.setTextViewText(R.id.widget_title_3, widgetData.getString("title_3", ""))
                    views.setTextViewText(R.id.widget_time_3, widgetData.getString("time_3", ""))
                } else {
                    views.setViewVisibility(R.id.widget_item_3, View.GONE)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
