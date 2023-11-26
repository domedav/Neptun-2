package com.domedav.neptun2;

import android.annotation.TargetApi;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.os.Build;
import android.widget.RemoteViews;

import androidx.annotation.NonNull;

public class TimeRemainingHomescreenWidgetProvider extends AppWidgetProvider {
	@Override
	public void onUpdate(Context context, AppWidgetManager appWidgetManager, @NonNull int[] appWidgetIds) {
		for (int appWidgetId : appWidgetIds) {
			RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.time_remaining_homescreen_widget);
			
			// Update the views based on your HomeScreenWidget
			
			appWidgetManager.updateAppWidget(appWidgetId, views);
		}
	}
}
