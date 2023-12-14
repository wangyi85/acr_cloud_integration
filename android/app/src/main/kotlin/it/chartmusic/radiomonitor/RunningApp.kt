package it.chartmusic.radiomonitor

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMethodCodec
import android.app.ActivityManager
import android.app.ActivityManager.RunningTaskInfo
import android.content.Context
import java.util.*

class RunningApp: FlutterPlugin, MethodCallHandler {
    private val CHANNEL = "RunningApp"
    private lateinit var channel : MethodChannel
    private lateinit var context : Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val taskQueue = flutterPluginBinding.binaryMessenger.makeBackgroundTaskQueue()
        context = flutterPluginBinding.getApplicationContext()
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL, StandardMethodCodec.INSTANCE, taskQueue)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getRunningApps") {
            val data = getRunningApps()
            result.success(data)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun getRunningApps(): String {
        // Perform platform-specific operations to fetch the data
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val recentTasks: List<RunningTaskInfo> = Objects.requireNonNull(activityManager).getRunningTasks(Int.MAX_VALUE)
        val apps = StringBuilder()
        for (i in recentTasks.indices) {
            apps.append(recentTasks[i].baseActivity!!.toShortString())
        }
        return apps.toString()
    }
}