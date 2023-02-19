package com.tonynowater.joyscalendar.joys_calendar

import android.os.Bundle
import android.util.Log
import com.zqc.opencc.android.lib.ChineseConverter
import com.zqc.opencc.android.lib.ConversionType
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL_OPENCC = "joyscalendar.opencc"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_OPENCC
        ).setMethodCallHandler { call, result ->
            val input = call.argument<String>("input")!!
            var output: String? = null
            when (call.method) {
                "convertToTraditionalChinese" -> {
                    output = convertToTraditionalChinese(input)
                }
                "convertToSimplifiedChinese" -> {
                    output = convertToSimplifiedChinese(input)
                }
                "convertToJapanese" -> {
                    output = convertToJapanese(input)
                }
            }
            if (output == null) {
                result.error(
                    "500",
                    "Can't convert, input=$input, method=${call.method}",
                    null
                )
            } else {
                result.success(output)
            }
        }
    }

    private fun convertToTraditionalChinese(simplifiedChinese: String): String? {
        return ChineseConverter.convert(simplifiedChinese, ConversionType.S2TWP, applicationContext)
    }

    private fun convertToSimplifiedChinese(traditionalChinese: String): String? {
        return ChineseConverter.convert(
            traditionalChinese,
            ConversionType.TW2SP,
            applicationContext
        )
    }

    private fun convertToJapanese(chinese: String): String? {
        return ChineseConverter.convert(chinese, ConversionType.T2JP, applicationContext)
    }

}
