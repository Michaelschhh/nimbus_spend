package com.example.nimbus_spend

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class NimbusWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: android.content.SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.nimbus_widget).apply {
                val allowanceStr = widgetData.getString("monthlyAllowance", "0.00") ?: "0.00"
                val spentStr = widgetData.getString("spentToday", "0.00") ?: "0.00"
                val currency = widgetData.getString("currency", "$") ?: "$"
                
                val primaryColorStr = widgetData.getString("primaryColor", "#FF2196F3") ?: "#FF2196F3"
                val textColorStr = widgetData.getString("textColor", "#FFFFFFFF") ?: "#FFFFFFFF"
                
                val primaryColor = android.graphics.Color.parseColor(primaryColorStr)
                val textColor = android.graphics.Color.parseColor(textColorStr)
                
                val allowance = allowanceStr.toFloatOrNull() ?: 0.0f
                val spent = spentStr.toFloatOrNull() ?: 0.0f

                setTextViewText(R.id.widget_balance, "$currency${String.format("%.2f", allowance)}")
                setTextColor(R.id.widget_balance, textColor)
                
                setTextViewText(R.id.widget_spent, "-$currency${String.format("%.2f", spent)}")
                setTextColor(R.id.widget_spent, primaryColor)
                
                val labelTextColor = (textColor and 0x00FFFFFF) or (160 shl 24)
                setTextColor(R.id.widget_balance_label, labelTextColor)
                setTextColor(R.id.widget_spent_label, labelTextColor)
                
                setTextColor(R.id.widget_status, primaryColor)
                
                // Set the primary color for the logo/brand text as well
                val brandTextColor = (textColor and 0x00FFFFFF) or (120 shl 24)
                setTextColor(R.id.widget_brand_text, brandTextColor)

                // Status logic
                if (allowance <= 0) {
                    setTextViewText(R.id.widget_status, "Depleted")
                    setTextColor(R.id.widget_status, 0xFFFF6B6B.toInt())
                } else if (spent > allowance * 0.5) {
                    setTextViewText(R.id.widget_status, "Caution")
                    setTextColor(R.id.widget_status, 0xFFFBBF24.toInt())
                } else {
                    setTextViewText(R.id.widget_status, "Healthy")
                    setTextColor(R.id.widget_status, 0xFF4ADE80.toInt())
                }

                // Click handlers
                val addIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, android.net.Uri.parse("nimbus://add_expense"))
                setOnClickPendingIntent(R.id.btn_add_expense, addIntent)

                val homeIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, android.net.Uri.parse("nimbus://home"))
                setOnClickPendingIntent(R.id.widget_balance, homeIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
