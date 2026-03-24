package com.akburak.deadline

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

class TaskWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_task)

            val count = widgetData.getInt("task_count", 0)

            if (count == 0) {
                views.setViewVisibility(R.id.widget_empty_text, View.VISIBLE)
                views.setViewVisibility(R.id.widget_item_1, View.GONE)
                views.setViewVisibility(R.id.widget_item_2, View.GONE)
                views.setViewVisibility(R.id.widget_item_3, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_empty_text, View.GONE)

                // Helper to initialize a task view
                fun bindTask(index: Int, containerId: Int, titleId: Int, checkId: Int,
                             sub1Id: Int, sub1Title: Int, sub1Check: Int,
                             sub2Id: Int, sub2Title: Int, sub2Check: Int) {
                    
                    val title = widgetData.getString("task_title_$index", null)
                    if (title.isNullOrEmpty()) {
                        views.setViewVisibility(containerId, View.GONE)
                        return
                    }
                    
                    views.setViewVisibility(containerId, View.VISIBLE)
                    views.setTextViewText(titleId, title)
                    val taskIdStr = widgetData.getString("task_id_$index", "")
                    val taskId = taskIdStr?.toIntOrNull() ?: 0
                    
                    val mainIntentUri = Uri.parse("appWidget://toggleTask?id=$taskId")
                    val mainIntentObj = android.content.Intent(context, es.antonborri.home_widget.HomeWidgetBackgroundReceiver::class.java).apply {
                        data = mainIntentUri
                        action = "es.antonborri.home_widget.action.BACKGROUND"
                    }
                    val mainIntent = android.app.PendingIntent.getBroadcast(
                        context,
                        (taskId * 100), // Unique request code
                        mainIntentObj,
                        android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(checkId, mainIntent)

                    // Subtasks
                    val subCount = widgetData.getInt("task_sub_count_$index", 0)

                    // Subtask 1
                    if (subCount >= 1) {
                        views.setViewVisibility(sub1Id, View.VISIBLE)
                        views.setTextViewText(sub1Title, widgetData.getString("task_sub_title_${index}_1", ""))
                        val subId1Str = widgetData.getString("task_sub_id_${index}_1", "")
                        val subId1 = subId1Str?.toIntOrNull() ?: 0
                        val isCompleted1 = widgetData.getBoolean("task_sub_completed_${index}_1", false)
                        
                        views.setImageViewResource(sub1Check, if (isCompleted1) android.R.drawable.checkbox_on_background else android.R.drawable.checkbox_off_background)
                        
                        val subIntentUri1 = Uri.parse("appWidget://toggleSubTask?taskId=$taskId&subTaskId=$subId1")
                        val subIntentObj1 = android.content.Intent(context, es.antonborri.home_widget.HomeWidgetBackgroundReceiver::class.java).apply {
                            data = subIntentUri1
                            action = "es.antonborri.home_widget.action.BACKGROUND"
                        }
                        val subIntent1 = android.app.PendingIntent.getBroadcast(
                            context,
                            (subId1 * 1000) + 1,
                            subIntentObj1,
                            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                        )
                        views.setOnClickPendingIntent(sub1Check, subIntent1)
                    } else {
                        views.setViewVisibility(sub1Id, View.GONE)
                    }

                    // Subtask 2
                    if (subCount >= 2) {
                        views.setViewVisibility(sub2Id, View.VISIBLE)
                        views.setTextViewText(sub2Title, widgetData.getString("task_sub_title_${index}_2", ""))
                        val subId2Str = widgetData.getString("task_sub_id_${index}_2", "")
                        val subId2 = subId2Str?.toIntOrNull() ?: 0
                        val isCompleted2 = widgetData.getBoolean("task_sub_completed_${index}_2", false)
                        
                        views.setImageViewResource(sub2Check, if (isCompleted2) android.R.drawable.checkbox_on_background else android.R.drawable.checkbox_off_background)
                        
                        val subIntentUri2 = Uri.parse("appWidget://toggleSubTask?taskId=$taskId&subTaskId=$subId2")
                        val subIntentObj2 = android.content.Intent(context, es.antonborri.home_widget.HomeWidgetBackgroundReceiver::class.java).apply {
                            data = subIntentUri2
                            action = "es.antonborri.home_widget.action.BACKGROUND"
                        }
                        val subIntent2 = android.app.PendingIntent.getBroadcast(
                            context,
                            (subId2 * 1000) + 2,
                            subIntentObj2,
                            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                        )
                        views.setOnClickPendingIntent(sub2Check, subIntent2)
                    } else {
                        views.setViewVisibility(sub2Id, View.GONE)
                    }
                }

                val pinnedTaskId = widgetData.getString("pinned_task_widget_$appWidgetId", "")
                
                if (pinnedTaskId.isNullOrEmpty()) {
                    // Dynamic mode (Top 2 tasks)
                    if (count >= 1) {
                        bindTask(1, R.id.widget_item_1, R.id.widget_title_1, R.id.widget_check_1,
                                 R.id.widget_subitem_1_1, R.id.widget_subtitle_1_1, R.id.widget_subcheck_1_1,
                                 R.id.widget_subitem_1_2, R.id.widget_subtitle_1_2, R.id.widget_subcheck_1_2)
                    } else {
                        views.setViewVisibility(R.id.widget_item_1, View.GONE)
                    }

                    if (count >= 2) {
                        bindTask(2, R.id.widget_item_2, R.id.widget_title_2, R.id.widget_check_2,
                                 R.id.widget_subitem_2_1, R.id.widget_subtitle_2_1, R.id.widget_subcheck_2_1,
                                 R.id.widget_subitem_2_2, R.id.widget_subtitle_2_2, R.id.widget_subcheck_2_2)
                    } else {
                        views.setViewVisibility(R.id.widget_item_2, View.GONE)
                    }
                } else {
                    // Pinned mode (Show specifically chosen task)
                    var foundIndex = 1
                    for (i in 1..count) {
                        if (widgetData.getString("task_id_$i", "") == pinnedTaskId) {
                            foundIndex = i
                            break
                        }
                    }
                    bindTask(foundIndex, R.id.widget_item_1, R.id.widget_title_1, R.id.widget_check_1,
                             R.id.widget_subitem_1_1, R.id.widget_subtitle_1_1, R.id.widget_subcheck_1_1,
                             R.id.widget_subitem_1_2, R.id.widget_subtitle_1_2, R.id.widget_subcheck_1_2)
                    
                    // Hide 2nd slot since it's a specific single pinned task widget
                    views.setViewVisibility(R.id.widget_item_2, View.GONE)
                }

            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
