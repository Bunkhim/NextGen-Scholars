-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.engine.** { *; }

-keep class com.google.** { *; }
-keep class com.facebook.** { *; }
-keep class com.it_nomads.** { *; }
-keep class com.tekartik.** { *; }
-keep class app.meedu.** { *; }
-keep class com.github.dart_lang.** { *; }

-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

-dontwarn android.**
-dontwarn androidx.**
-dontwarn com.google.**
-dontwarn com.facebook.**

-keep class com.example.scholarship_app.** { *; }

-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
}

-assumenosideeffects class java.io.PrintStream {
    public void println(...);
}

-assumenosideeffects class kotlin.io.** {
    static void println(...);
}

-assumenosideeffects class java.lang.Exception {
    public void printStackTrace();
}
