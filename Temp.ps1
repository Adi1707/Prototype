# Prerequisites:
# 1. Install the 'Oracle.ManagedDataAccess' module using the following command:
#    Install-Module -Name Oracle.ManagedDataAccess -Scope CurrentUser
# 2. Import the module before running the script:
#    Import-Module Oracle.ManagedDataAccess

$sharePath = "\\samba-server\share"  # Replace with the actual Samba share path
$destinationPath = "C:\Destination"  # Replace with the desired destination path on the local machine

# Oracle database connection details
$oracleUsername = "your-username"  # Replace with the Oracle username
$oraclePassword = "your-password"  # Replace with the Oracle password
$oracleConnectionString = "Data Source=your-database-host:your-port/your-service-name;User Id=$oracleUsername;Password=$oraclePassword"

# Function to fetch files from Samba share
function Fetch-SambaData {
    param(
        [string]$SharePath,
        [string]$DestinationPath
    )

    # Check if the destination path exists, if not, create it
    if (-not (Test-Path -Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath | Out-Null
    }

    # Mount the Samba share as a network drive
    $driveLetter = "Z"  # Choose an available drive letter
    $password = ConvertTo-SecureString -String "samba-password" -AsPlainText -Force  # Replace with the Samba password
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "samba-username", $password  # Replace with the Samba username
    New-PSDrive -Name $driveLetter -PSProvider FileSystem -Root $SharePath -Credential $credential | Out-Null

    # Copy files from the Samba share to the destination path
    Copy-Item -Path "$driveLetter`:\" -Destination $DestinationPath -Recurse -Force

    # Unmount the network drive
    Remove-PSDrive -Name $driveLetter
}

# Call the function to fetch data from the Samba share
Fetch-SambaData -SharePath $sharePath -DestinationPath $destinationPath

# Process and save data to Oracle database
try {
    # Import the Oracle.ManagedDataAccess module
    Import-Module Oracle.ManagedDataAccess

    # Establish a connection to the Oracle database
    $connection = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($oracleConnectionString)
    $connection.Open()

    # Iterate through the files in the destination path
    $files = Get-ChildItem -Path $destinationPath -File
    foreach ($file in $files) {
        # Read the contents of the file
        $fileContent = Get-Content -Path $file.FullName

        # Insert the file content into the Oracle database
        $sql = "INSERT INTO your_table_name (file_name, file_content) VALUES (:fileName, :fileContent)"
        $command = New-Object Oracle.ManagedDataAccess.Client.OracleCommand($sql, $connection)
        $command.Parameters.Add(":fileName", $file.Name) | Out-Null
        $command.Parameters.Add(":fileContent", $fileContent) | Out-Null
        $command.ExecuteNonQuery() | Out-Null

        Write-Host "Inserted file: $($file.Name)"
    }

    $connection.Close()
}
