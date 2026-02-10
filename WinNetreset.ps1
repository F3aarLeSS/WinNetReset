# ================================
# LOAD ASSEMBLIES
# ================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# ================================
# ADMIN CHECK
# ================================
function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Administrator privileges are required for network reset.",
        "Permission Required",
        "OK",
        "Error"
    )
    exit
}

# ================================
# FORM (ICON MUST BE SET EARLY)
# ================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Network Reset"
$form.Size = New-Object System.Drawing.Size(500, 360)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.AutoScaleMode = 'Dpi'
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# 🔴 TASK MANAGER ICON FIX (CRITICAL)
$exeDir   = [AppDomain]::CurrentDomain.BaseDirectory
$iconPath = Join-Path $exeDir "netreset.ico"
if (Test-Path $iconPath) {
    $form.Icon = New-Object System.Drawing.Icon($iconPath)
}

# ================================
# TITLE
# ================================
$title = New-Object System.Windows.Forms.Label
$title.Text = "Windows Network Reset"
$title.Font = New-Object System.Drawing.Font(
    "Segoe UI", 14, [System.Drawing.FontStyle]::Bold
)
$title.AutoSize = $true
$title.Location = '135,15'
[void]$form.Controls.Add($title)

# ================================
# GROUP BOX
# ================================
$group = New-Object System.Windows.Forms.GroupBox
$group.Text = "Reset options"
$group.Size = '440,120'
$group.Location = '25,55'
[void]$form.Controls.Add($group)

$cbIP = New-Object System.Windows.Forms.CheckBox
$cbIP.Text = "Reset IP (Release / Renew)"
$cbIP.Checked = $true
$cbIP.Location = '15,30'
[void]$group.Controls.Add($cbIP)

$cbDNS = New-Object System.Windows.Forms.CheckBox
$cbDNS.Text = "Flush DNS Cache"
$cbDNS.Checked = $true
$cbDNS.Location = '15,55'
[void]$group.Controls.Add($cbDNS)

$cbWinsock = New-Object System.Windows.Forms.CheckBox
$cbWinsock.Text = "Reset Winsock / TCP-IP"
$cbWinsock.Checked = $true
$cbWinsock.Location = '230,30'
[void]$group.Controls.Add($cbWinsock)

# ================================
# STATUS + PROGRESS
# ================================
$status = New-Object System.Windows.Forms.Label
$status.Text = "Ready"
$status.Location = '25,190'
[void]$form.Controls.Add($status)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = '25,215'
$progress.Size = '440,20'
$progress.Style = 'Blocks'
[void]$form.Controls.Add($progress)

# ================================
# BUTTONS
# ================================
$aboutBtn = New-Object System.Windows.Forms.Button
$aboutBtn.Text = "About"
$aboutBtn.Size = '90,32'

$startBtn = New-Object System.Windows.Forms.Button
$startBtn.Text = "Start Reset"
$startBtn.Size = '140,32'
$startBtn.Font = New-Object System.Drawing.Font(
    "Segoe UI", 9, [System.Drawing.FontStyle]::Bold
)

$exitBtn = New-Object System.Windows.Forms.Button
$exitBtn.Text = "Exit"
$exitBtn.Size = '90,32'

$btnPanel = New-Object System.Windows.Forms.TableLayoutPanel
$btnPanel.RowCount = 1
$btnPanel.ColumnCount = 3
$btnPanel.Size = '440,40'
$btnPanel.Location = '25,260'

[void]$btnPanel.ColumnStyles.Add(
    (New-Object System.Windows.Forms.ColumnStyle(
        [System.Windows.Forms.SizeType]::Percent, 33)))
[void]$btnPanel.ColumnStyles.Add(
    (New-Object System.Windows.Forms.ColumnStyle(
        [System.Windows.Forms.SizeType]::Percent, 34)))
[void]$btnPanel.ColumnStyles.Add(
    (New-Object System.Windows.Forms.ColumnStyle(
        [System.Windows.Forms.SizeType]::Percent, 33)))

$aboutBtn.Anchor = 'None'
$startBtn.Anchor = 'None'
$exitBtn.Anchor = 'None'

[void]$btnPanel.Controls.Add($aboutBtn, 0, 0)
[void]$btnPanel.Controls.Add($startBtn, 1, 0)
[void]$btnPanel.Controls.Add($exitBtn, 2, 0)
[void]$form.Controls.Add($btnPanel)

# ================================
# EVENTS
# ================================
$exitBtn.Add_Click({ $form.Close() })

$aboutBtn.Add_Click({
    $githubUrl = "https://github.com/F3aarLeSS/WinTempCleaner"

    $msg = "Windows Network Reset v1.0`n`n" +
           "Author: Navajyoti Bayan`n`n" +
           "Resets Windows network components:`n" +
           "• IP configuration`n" +
           "• DNS cache`n" +
           "• Winsock / TCP-IP stack`n`n" +
           "Internet may disconnect temporarily.`n`n" +
           "GitHub:`n$githubUrl"

    if ([System.Windows.Forms.MessageBox]::Show(
        $msg,
        "About",
        "OKCancel",
        "Information"
    ) -eq "OK") {
        Start-Process $githubUrl
    }
})

# ================================
# START RESET
# ================================
$startBtn.Add_Click({

    if (-not ($cbIP.Checked -or $cbDNS.Checked -or $cbWinsock.Checked)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Please select at least one reset option.",
            "Warning"
        )
        return
    }

    if ([System.Windows.Forms.MessageBox]::Show(
        "Network will reset and internet may disconnect temporarily.`nContinue?",
        "Confirm",
        "YesNo",
        "Question"
    ) -ne "Yes") { return }

    $startBtn.Enabled = $false
    $status.Text = "Resetting network..."
    $progress.Style = 'Marquee'
    $form.Refresh()

    if ($cbIP.Checked) {
        ipconfig /release | Out-Null
        ipconfig /renew   | Out-Null
    }

    if ($cbDNS.Checked) {
        ipconfig /flushdns | Out-Null
    }

    if ($cbWinsock.Checked) {
        netsh winsock reset | Out-Null
        netsh int ip reset  | Out-Null
    }

    $progress.Style = 'Blocks'
    $progress.Value = 100
    $status.Text = "Completed"
    $startBtn.Enabled = $true

    [System.Windows.Forms.MessageBox]::Show(
        "Network reset completed successfully.`nA system restart is recommended.",
        "Done",
        "OK",
        "Information"
    )
})

# ================================
# RUN
# ================================
[void]$form.ShowDialog()
