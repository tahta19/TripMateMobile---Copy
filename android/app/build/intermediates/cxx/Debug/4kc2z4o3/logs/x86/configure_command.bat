@echo off
"C:\\Users\\dinda\\AppData\\Local\\Android\\sdk\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HD:\\I C H A\\UNIVERSITY\\TOOLS\\flutter\\packages\\flutter_tools\\gradle\\src\\main\\groovy" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=21" ^
  "-DANDROID_PLATFORM=android-21" ^
  "-DANDROID_ABI=x86" ^
  "-DCMAKE_ANDROID_ARCH_ABI=x86" ^
  "-DANDROID_NDK=C:\\Users\\dinda\\AppData\\Local\\Android\\Sdk\\ndk\\25.1.8937393" ^
  "-DCMAKE_ANDROID_NDK=C:\\Users\\dinda\\AppData\\Local\\Android\\Sdk\\ndk\\25.1.8937393" ^
  "-DCMAKE_TOOLCHAIN_FILE=C:\\Users\\dinda\\AppData\\Local\\Android\\Sdk\\ndk\\25.1.8937393\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=C:\\Users\\dinda\\AppData\\Local\\Android\\sdk\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=D:\\I C H A\\UNIVERSITY\\SEMESTER 4\\PEMROGRAMAN MOBILE\\tripmate_mobile\\android\\app\\build\\intermediates\\cxx\\Debug\\4kc2z4o3\\obj\\x86" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=D:\\I C H A\\UNIVERSITY\\SEMESTER 4\\PEMROGRAMAN MOBILE\\tripmate_mobile\\android\\app\\build\\intermediates\\cxx\\Debug\\4kc2z4o3\\obj\\x86" ^
  "-DCMAKE_BUILD_TYPE=Debug" ^
  "-BD:\\I C H A\\UNIVERSITY\\SEMESTER 4\\PEMROGRAMAN MOBILE\\tripmate_mobile\\android\\app\\.cxx\\Debug\\4kc2z4o3\\x86" ^
  -GNinja ^
  -Wno-dev ^
  --no-warn-unused-cli
