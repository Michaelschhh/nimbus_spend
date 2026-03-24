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
                val balance = widgetData.getFloat("balance", 0.0f)
                val spent = widgetData.getFloat("spentToday", 0.0f)
                val currency = widgetData.getString("currency", "$") ?: "$"

                setTextViewText(R.id.widget_balance, "$currency${String.format("%.2f", balance)}")
                setTextViewText(R.id.widget_spent, "-$currency${String.format("%.2f", spent)}")

                // Status logic
                if (balance <= 0) {
                    setTextViewText(R.id.widget_status, "Depleted")
                    setTextColor(R.id.widget_status, 0xFFFF6B6B.toInt())
                } else if (spent > balance * 0.5) {
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
