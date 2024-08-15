# Path to the Windows Terminal executable
$wtPath = "wt.exe"

# Commands to launch 3 tabs with split panes and SSH connections
$commands = @(
    "new-tab -p 'PowerShell' ssh wolfhost@10.10.100.51 ; split-pane -V -p 'PowerShell' ssh wolfhost@10.10.100.52 ; split-pane -H -p 'PowerShell' ssh wolfhost@10.10.100.53",
    "new-tab -p 'PowerShell' ssh wolfhost@10.10.100.61 ; split-pane -V -p 'PowerShell' ssh wolfhost@10.10.100.62 ; split-pane -H -p 'PowerShell' ssh wolfhost@10.10.100.63",
    "new-tab -p 'PowerShell' ssh wolfhost@10.10.100.71 ; split-pane -V -p 'PowerShell' ssh wolfhost@10.10.100.72 ; split-pane -H -p 'PowerShell' ssh wolfhost@10.10.100.73"
)

# Join the commands with " ; " to create a single command string
$commandString = $commands -join " ; "

# Launch the Windows Terminal with the constructed command string
Start-Process $wtPath -ArgumentList $commandString