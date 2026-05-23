# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# WorkManager + Room (required for release minification)
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.InputMerger
-keep class * extends androidx.work.ListenableWorker { *; }
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-keepclassmembers class * extends androidx.room.RoomDatabase {
    <init>(...);
}
-keepclassmembers class * {
    @androidx.work.Worker *;
}
