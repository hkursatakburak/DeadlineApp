package com.akburak.deadline

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.RadioButton
import android.widget.RadioGroup

class WidgetConfigActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_widget_config)

        setResult(RESULT_CANCELED)

        val intent = intent
        val extras = intent.extras
        if (extras != null) {
            appWidgetId = extras.getInt(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
        }

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        val radioGroup = findViewById<RadioGroup>(R.id.config_radio_group)
        val btnSave = findViewById<Button>(R.id.btn_save_config)

        // The default SharedPreferences name for home_widget on Android
        val prefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val taskCount = prefs.getInt("task_count", 0)

        for (i in 1..taskCount) {
            val taskId = prefs.getString("task_id_$i", "")
            val title = prefs.getString("task_title_$i", "Belirsiz Görev")
            
            if (taskId?.isNotEmpty() == true) {
                val rb = RadioButton(this)
                rb.text = title
                rb.tag = taskId
                rb.setTextColor(android.graphics.Color.parseColor("#E0E0E0"))
                rb.textSize = 16f
                rb.setPadding(8, 16, 8, 16)
                radioGroup.addView(rb)
            }
        }

        btnSave.setOnClickListener {
            val selectedId = radioGroup.checkedRadioButtonId
            var selectedTaskId = "" 
            
            if (selectedId != R.id.radio_dynamic && selectedId != -1) {
                val selectedRadio = findViewById<RadioButton>(selectedId)
                selectedTaskId = selectedRadio.tag as String
            }

            prefs.edit().putString("pinned_task_widget_$appWidgetId", selectedTaskId).apply()

            val appWidgetManager = AppWidgetManager.getInstance(this)
            
            val provider = TaskWidgetProvider()
            provider.onUpdate(this, appWidgetManager, intArrayOf(appWidgetId), prefs)

            val resultValue = Intent().apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            setResult(RESULT_OK, resultValue)
            finish()
        }
    }
}
