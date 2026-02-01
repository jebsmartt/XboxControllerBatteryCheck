# XboxControllerBatteryCheck

An alternative to check the battery life of Xbox Controllers connected via Bluetooth LE, featuring real-time status tracking and automated re-polling.

## Features

-   **Accurate Tracking:** Uses the specific Bluetooth LE "Active" flag to detect when the controller is truly on or off.

-   **Always-on-Top:** Stays visible over your games or apps.

-   **Low Resource Usage:** Polls hardware every 10 seconds to save battery and CPU.

-   **Instant Status:** Checks connectivity immediately upon launch.

## Installation & Setup

### 1\. Save the Script

1.  Copy the code from `XboxControllerBattery.ps1`.

2.  Save it to a folder on your PC (e.g., `Downloads` or a dedicated `Scripts` folder).

### 2\. Set Execution Policy

If you've never run a PowerShell script before, you may need to grant permission. Open PowerShell as Administrator and run:

PowerShell

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

```

### 3\. Create a "Stealth" Shortcut (Recommended)

To launch the app without a black console window appearing:

1.  **Right-click** your Desktop and select **New > Shortcut**.

2.  In the **Target** field, paste the following (adjust the file path if you saved the script elsewhere):

    Plaintext

    ```
    powershell.exe -WindowStyle Hidden -File "%USERPROFILE%\Downloads\XboxControllerBattery.ps1"

    ```

3.  Click **Next** and name it "Xbox Battery."


## Optional Enhancements

### Setting a Keyboard Shortcut

1.  Right-click your new "Xbox Battery" **desktop shortcut** > **Properties**.

2.  Click the **Shortcut** tab.

3.  Click in the **Shortcut key** box and press your desired combo (e.g., `Ctrl + Alt + B`).

4.  Click **Apply**.

### Launch on Startup

If you want the monitor to start every time you turn on your PC:

1.  Press `Win + R`, type `shell:startup`, and hit Enter.

2.  Copy your "Xbox Battery" shortcut into this folder.

### Change the Icon

1.  Right-click the shortcut > **Properties** > **Shortcut** tab.

2.  Click **Change Icon...** and browse for an `.ico` file or choose a system icon.


## License

This project is licensed under the [MIT License](https://www.google.com/search?q=LICENSE).
