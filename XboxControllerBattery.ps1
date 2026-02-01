# Hide the console window
$win = Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@ -Name "Win32ShowWindow" -Namespace Win32Functions -PassThru
$win::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- UI Setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Xbox Controller Battery Status"
$form.Width = 350
$form.Height = 160  # Slightly taller to accommodate the title bar + content
$form.TopMost = $true 
$form.FormBorderStyle = "FixedToolWindow"
$form.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)

# Positioning: Top-Right
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$form.Left = $screen.Width - $form.Width - 10
$form.Top = 10

# Main Status Label (Pushed up slightly)
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Size = New-Object System.Drawing.Size(350, 70)
$statusLabel.Location = New-Object System.Drawing.Point(0, 10)
$statusLabel.TextAlign = "MiddleCenter"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 26, [System.Drawing.FontStyle]::Bold)
$statusLabel.ForeColor = [System.Drawing.Color]::Gray
$statusLabel.Text = "---" 
$form.Controls.Add($statusLabel)

# Centered Timer Panel (Moved up to be visible)
$timerPanel = New-Object System.Windows.Forms.Panel
$timerPanel.Size = New-Object System.Drawing.Size(350, 30)
$timerPanel.Location = New-Object System.Drawing.Point(0, 85) # Adjusted to fit inside 160 height
$timerPanel.BackColor = [System.Drawing.Color]::Transparent
$form.Controls.Add($timerPanel)

# Centered Next Check Text
$descLabel = New-Object System.Windows.Forms.Label
$descLabel.Text = "Next check in 10s"
$descLabel.ForeColor = [System.Drawing.Color]::LightGray
$descLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$descLabel.TextAlign = "MiddleCenter"
$descLabel.Dock = "Fill"
$timerPanel.Controls.Add($descLabel)

$timerPanel.BringToFront()

# --- Timing Logic ---
$refreshInterval = 10000
$script:timeRemaining = $refreshInterval

$logicTimer = New-Object System.Windows.Forms.Timer
$logicTimer.Interval = $refreshInterval

$uiTimer = New-Object System.Windows.Forms.Timer
$uiTimer.Interval = 1000 

$CheckBattery = {
    $controllers = Get-PnpDevice -Class 'Bluetooth' -FriendlyName "Xbox*" -ErrorAction SilentlyContinue 
    $activeDisplay = New-Object System.Collections.Generic.List[string]

    foreach ($dev in $controllers) {
        $isActive = Get-PnpDeviceProperty -InstanceId $dev.InstanceId -KeyName '{83DA6326-97A6-4088-9453-A1923F573B29} 15' -ErrorAction SilentlyContinue
        if ($isActive.Data -eq $true) {
            $battery = Get-PnpDeviceProperty -InstanceId $dev.InstanceId -KeyName '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2' -ErrorAction SilentlyContinue
            if ($battery.Data) { $activeDisplay.Add("$($battery.Data)%") }
        }
    }

    if ($activeDisplay.Count -gt 0) {
        $statusLabel.Text = $activeDisplay -join " | "
        $statusLabel.ForeColor = [System.Drawing.Color]::White
        $form.BackColor = [System.Drawing.Color]::FromArgb(16, 124, 16)
        $descLabel.ForeColor = [System.Drawing.Color]::White
    } else {
        $statusLabel.Text = "OFF"
        $statusLabel.ForeColor = [System.Drawing.Color]::Gray
        $form.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
        $descLabel.ForeColor = [System.Drawing.Color]::LightGray
    }
    $script:timeRemaining = $refreshInterval
}

$logicTimer.Add_Tick({ &$CheckBattery })

$uiTimer.Add_Tick({
    $script:timeRemaining -= 1000
    if ($script:timeRemaining -lt 0) { $script:timeRemaining = 0 }
    $seconds = [math]::Floor($script:timeRemaining / 1000)
    $descLabel.Text = "Next check in $($seconds)s"
})

$form.Add_Load({ 
    &$CheckBattery
    $logicTimer.Start()
    $uiTimer.Start()
})

$form.Add_FormClosing({ 
    $logicTimer.Stop()
    $uiTimer.Stop()
    Stop-Process -Id $pid 
})

$form.ShowDialog()