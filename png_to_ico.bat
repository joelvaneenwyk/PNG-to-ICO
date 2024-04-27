@ECHO OFF
GOTO:$MAIN
REM
REM    Name :
REM          PNG to ICO
REM    Author :
REM          ▄▄▄▄▄▄▄  ▄ ▄▄ ▄▄▄▄▄▄▄
REM          █ ▄▄▄ █ ██ ▀▄ █ ▄▄▄ █
REM          █ ███ █ ▄▀ ▀▄ █ ███ █
REM          █▄▄▄▄▄█ █ ▄▀█ █▄▄▄▄▄█
REM          ▄▄ ▄  ▄▄▀██▀▀ ▄▄▄ ▄▄
REM           ▀█▄█▄▄▄█▀▀ ▄▄▀█ █▄▀█
REM           █ █▀▄▄▄▀██▀▄ █▄▄█ ▀█
REM          ▄▄▄▄▄▄▄ █▄█▀ ▄ ██ ▄█
REM          █ ▄▄▄ █  █▀█▀ ▄▀▀  ▄▀
REM          █ ███ █ ▀▄  ▄▀▀▄▄▀█▀█
REM          █▄▄▄▄▄█ ███▀▄▀ ▀██ ▄
REM

:CONVERT_FILE
SETLOCAL ENABLEDELAYEDEXPANSION
  SET "input_file_path=%~dpf1"
  SET "target_path=%~dp2"
  IF "%target_path:~-1%"=="\" SET "target_path=%target_path:~0,-1%"
  SET "target_file_path=!target_path!\%~n1.ico"

  SET "MAGICK_CODER_MODULE_PATH=%USERPROFILE%\scoop\apps\imagemagick\current\modules\coders"
  IF NOT EXIST "!MAGICK_CODER_MODULE_PATH!" (
    SET "MAGICK_CODER_MODULE_PATH="
  ) ELSE (
    SET "PATH=%PATH%;!MAGICK_CODER_MODULE_PATH!"
  )

  SET "image_magick_path=%USERPROFILE%\scoop\apps\imagemagick\current\magick.exe"
  SET "image_magick_cmd=convert"
  IF EXIST "!image_magick_path!" (
    CD /D "%USERPROFILE%\scoop\apps\imagemagick\current"
  ) ELSE (
    SET "image_magick_path=%~dp0ImageMagick\convert.exe"
    SET "image_magick_cmd="
  )
  IF NOT EXIST "!image_magick_path!" GOTO:$CONVERT_FILE_MISSING_MAGICK

  :$CONVERT_FILE_RUN
      :: Convert file to multi-resolution ICO
      SET image_magick_args=!image_magick_cmd! "!input_file_path!" -compress none -define "icon:auto-resize=256,128,96,64,48,32,24,16" "!target_file_path!"
      ECHO ##[cmd] "!image_magick_path!" !image_magick_args!
      CALL "!image_magick_path!" !image_magick_args!
      GOTO:$CONVERT_FILE_DONE

  :$CONVERT_FILE_MISSING_MAGICK
    ECHO [ERROR] Failed to find ImageMagick: "!image_magick_path!"
    GOTO:$CONVERT_FILE_DONE

  :$CONVERT_FILE_DONE
ENDLOCAL & EXIT /B %ERRORLEVEL%

:CONVERT_ALL
SETLOCAL ENABLEDELAYEDEXPANSION
  SET "arg_path=%~1"
  SET "target_path=%~dp2"
  ECHO Source: "!arg_path!"
  ECHO Target: "!target_path!"
  REM If first argument is a directory
  IF EXIST "!arg_path!\*" GOTO:$CONVERT_ALL_DIRECTORY
  IF EXIST "!arg_path!\*" GOTO:$CONVERT_ALL_FILE

  :$CONVERT_ALL_DIRECTORY
    REM Iterate through PNG, GIF, BMP, SVG and JPG files in directory
    FOR %%f IN ("!arg_path!\*.png" "!arg_path!\*.bmp" "!arg_path!\*.gif" "!arg_path!\*.jpg" "!arg_path!\*.jpeg" "!arg_path!\*.svg") DO (
      call :CONVERT_FILE "%%f" "!target_path!"
      if errorlevel 1 goto:$CONVERT_ALL_DONE
    )
    GOTO:$CONVERT_ALL_DONE

  REM If first argument is a file
  :$CONVERT_ALL_FILE
    REM ECHO File : !arg_path!
    FOR %%f IN ("!arg_path!") DO (
      call :CONVERT_FILE "%%f"
      if errorlevel 1 goto:$CONVERT_ALL_DONE
    )
    GOTO:$CONVERT_ALL_DONE

    :$CONVERT_ALL_DONE
ENDLOCAL & EXIT /B %ERRORLEVEL%

:$MAIN
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
  TITLE PNG to ICO
  ECHO.
  ECHO   -------------------------------------------------------------
  ECHO              PNG to ICO
  ECHO   -------------------------------------------------------------
  ECHO.

  SET "input_argument=%~1"
  IF "!input_argument!"=="" SET "input_argument=%~dp0..\PNGs"
  SET "target_path=%input_argument:PNGs=ICO%"

  CALL :CONVERT_ALL "!input_argument!" "%target_path%\"
ENDLOCAL & EXIT /b %ERRORLEVEL%
