#-----------------------------------------------------------------------------------------------------------
# Description: This script uses a template to create a set of piper files then runs them concurrently as 
#              background jobs.
# Author:      Sean Mullane / spm9r
# Date:        5/26/2017
# Modified:    6/14/2018
# 
# Copyright University of Virginia 2017
#-----------------------------------------------------------------------------------------------------------

###FIX Need to set up some error reporting from this script (maybe email to me and others?)

###FIX need to ensure that ytex config file isn't set to use YTEX database before running


# Script parameters

param(
[Parameter(Mandatory=$true)]
[string]$pipertemplate,
[ValidateSet("note_batch_ids")]
[string]$idTable = 'note_batch_ids',
[ValidateSet("uspSrc_cTAKES_notes_batch_table_trec")] 
[string]$batchProc = 'uspSrc_cTAKES_notes_batch_table_trec',
[string]$beginDte = $NULL,
[string]$endDte = $NULL,
[Parameter(Mandatory=$true)]
[string]$analysisBatch,
[int][validateRange(1,100000000)]$docQuantity = 100000,
[ValidateSet("pub_abstract","clinical_trial")] 
[string]$docType = 'pub_abstract',
[int][validateRange(0,1)]$debug = 0,
[int][validateRange(1,22)]$threads = 5,
[string]$logpath, # default value set below only if $env:CTAKES_HOME is found
[boolean]$logtoconsole = $false,
[boolean]$initcheck = $true
)

# Create logging function

Function LogWrite {
    Param (
		[string]$logstring,
		[string]$path = $logpath,
        [boolean]$echo = $logtoconsole
    )
	
    $stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $line = "$stamp $logstring"

    if ($echo) {
        Write-Output $line
    } else {
        Add-Content $path -value $line
    }        
}

$LogWriteDef = "function LogWrite { ${function:LogWrite} }" # create def as variable for redefinition in scriptblock

# Set environment variables

if (!([String]::IsNullOrEmpty($env:CTAKES_HOME))) {
    $env:PATH=$env:PATH+";"+$env:CTAKES_HOME+"\lib\auth\x64"
    #Write-Host $env:PATH
} else {
    Write-Host "Error: env:CTAKES_HOME not found - check whether this environment variable has been set"
    #Pause
    exit 1
}

if (!([String]::IsNullOrEmpty($env:JAVA_HOME))) {
    $env:PATH=$env:JAVA_HOME+"\bin;"+$env:PATH
    #Write-Host $env:PATH
} else {
    Write-Host "Error: env:JAVA_HOME not found - check whether this environment variable has been set"
    #Pause
    exit 1
}

# Check validity of parameters

if ([String]::IsNullOrEmpty($logpath)) {
    $logpath=$env:CTAKES_HOME+"\logs\backanno_run_TREC.log"
    if (!$logtoconsole) {
        Write-Host "No log file specified and `$logtoconsole set to false: logging to $logpath."
    }
} elseif (!(Test-Path $logpath)) {
    Write-Host "Error: logpath not found - check whether this parameter has been correctly specified"
    exit 1
}

if (!(Test-Path $env:CTAKES_HOME"\"$pipertemplate)) {
    LogWrite "Error: piper template file not found - check whether this parameter has been correctly specified"
    exit 1
}

if (!([String]::IsNullOrEmpty($beginDte) -or [string]$beginDte -as [DateTime])) {    
    LogWrite "Error: beginDte is not null or a date - check whether this parameter has been correctly specified"
    exit 1
}

if (!([String]::IsNullOrEmpty($endDte) -or [string]$endDte -as [DateTime])) {    
    LogWrite "Error: endDte is not null or a date - check whether this parameter has been correctly specified"
    exit 1
}

# Format params as necessary for SQL

if ([String]::IsNullOrEmpty($beginDte)) {
    $beginDte = 'NULL'
} else {
    $beginDte = "`'$beginDte`'"
}

if ([String]::IsNullOrEmpty($endDte)) {
    $endDte = 'NULL'
} else {
    $endDte = "`'$endDte`'"
}

$analysisBatch = "`'$analysisBatch`'"


LogWrite "#-------------------------------------------------------------------------------------------------#"
LogWrite "Running document batch fetch procedure..."

#Import-Module "sqlps" -DisableNameChecking

# The query parameters are hardcoded here but can be turned into parameters for this script
$query = "
DECLARE @outStatus BIT; 
EXECUTE [Rptg].[{0}] 
/*@beginDte*/ {1}  
,/*@endDte*/ {2}  
,/*@analysisBatch*/ {3] 
,/*@quantity*/ {4}
,/*@docType*/ {5}
,/*@debug*/ {6}
,@outStatus OUTPUT; 
SELECT @outStatus;" -f $batchProc,$beginDte,$endDte,$analysisBatch,$docQuantity,$docType,$debug

#'Social Work Progress %' 

$procResult = Invoke-Sqlcmd -Query $query -ServerInstance "localhost" -Database "TREC" -QueryTimeout 180 -verbose 4>&1

# split verbose output from data output
$resultData = $procResult | ?{$_ -is [System.Data.Datarow]}
$resultVerboseOut = $procResult | ?{$_ -is [System.Management.Automation.VerboseRecord]}

if($resultData.Count -eq 2) {
    # rowcount not returned in all cases; handle case where it is here
    $rowCount = $resultData[0].Column1
    $procFailure = $resultData[1].Column1
    $toWrite = "Rows added to Rptg.note_batch_ids: " + $rowCount
    LogWrite $toWrite
} else {
    $procFailure = $resultData.Column1
    $toWrite = "Procedure failed to load rows: " + $resultData.Column1
	LogWrite $toWrite
}

if($resultVerboseOut.Count -gt 0) {
    LogWrite "Begin messages from SQL Server: "
    foreach ($item in $resultVerboseOut) {
        LogWrite $item
    }
    LogWrite "End messages from SQL Server."
}

if($procFailure) {
    LogWrite "Procedure failed to load rows; exiting."
    #Pause
    exit 1
}

if (!($rowCount -and $rowCount -gt 0)) { 
    LogWrite "Rowcount is NULL or 0: exiting"
    #Pause
    exit 1
}

#LogWrite "#-------------------------------------------------------------------------------------------------#"
LogWrite "cTAKES annotation piper-runner script starting..."

# Create piper files from template

$tempPiperPath = "C:\Temp\pipers"

if (!(Test-Path $tempPiperPath)) {
    New-Item $tempPiperPath -itemType directory
} else {
    if (!([String]::IsNullOrEmpty($tempPiperPath))) {
        Get-ChildItem -Path $tempPiperPath -Include *.piper -File -Recurse | foreach {$_.Delete()}
    }
}

LogWrite "Creating $threads piper files from template $env:CTAKES_HOME\$pipertemplate"

for($i = 0; $i -lt $threads; $i++) {
    (Get-Content $env:CTAKES_HOME"\"$pipertemplate). `
    replace('_pipelineCount_', $threads). `
    replace('_pipelineNumber_', $i) | `
    Set-Content $tempPiperPath"\temp_piper_"$i".piper"
}

# Set parameters for Java file run

LogWrite "Setting environment variables"

$CLASS_PATH=$env:CTAKES_HOME+"\desc\;"+$env:CTAKES_HOME+"\resources\;"+$env:CTAKES_HOME+"\lib\*"
$LOG4J_PARM="-Dlog4j.configuration=file:\"+$env:CTAKES_HOME+"\config\log4j.xml"
$PIPE_RUNNER="org.apache.ctakes.core.pipeline.PiperFileRunner"

# Check ytex.properties file and swap in alternate version to ensure TREC database is used.

$ytPath = $env:CTAKES_HOME+"\resources\org\apache\ctakes\ytex"
$ytBkpPath = $env:CTAKES_HOME+"\properties backup"
$trecHashConst = "BE43BB8CB62C1B403F06C045A1E195C81255018B2DD1D895D23435D0398497BB" # This needs to be updated after any change to the file.

if((Test-Path -Path "$ytPath") -and (Test-Path -Path "$ytBkpPath\ytex_trec.properties")) {
    $ytbHash = (Get-FileHash -Path "$ytBkpPath\ytex_trec.properties").Hash
    if($ytbHash.Equals($trecHashConst)) { 
        Copy-Item -Path "$ytBkpPath\ytex_trec.properties" -Destination "$ytPath\ytex.properties" -Force
        LogWrite "Copied ytex_trec.properties over ytex.properties to ensure TREC database is used."
    } else {
	    LogWrite "ERROR: Failed to copy ytex_trec.properties over ytex.properties."
	    LogWrite "#-------------------------------------------------------------------------------------------------#"
        Exit 1
    }
}

# Check that the copy worked as expected

$ytHashNew = (Get-FileHash -Path "$ytPath\ytex.properties").Hash
if(!($ytHashNew.Equals($trecHashConst))) { 
    LogWrite "ERROR: Hash of ytex.properties does not match expected value. It may be misconfigured."
	LogWrite "#-------------------------------------------------------------------------------------------------#"
    Exit 1
}


# Loop through constructed piper files and start as background jobs

LogWrite "Starting cTAKES CPEs"

Get-ChildItem -Path $tempPiperPath -Include *.piper -File -Recurse | %{
    $ScriptBlock = {
        param(
            $name,
            $CTAKES_HOME,
            $CLASS_PATH, 
            $LOG4J_PARM, 
            $PIPE_RUNNER,
			$LogWriteDef, # Needed to make logging from background jobs work, along with $logpath and $logtoconsole.
			$logpath,
			$logtoconsole
        )
		
		(iex $LogWriteDef) # Create function in local context
		
        LogWrite "Starting annotation using pipeline: $name"
        LogWrite "using parameters:"
        LogWrite "CLASS_PATH: $CLASS_PATH"
        LogWrite "LOG4J_PARM: $LOG4J_PARM"
        LogWrite "Java main class: $PIPE_RUNNER"
		& java -cp "$CLASS_PATH" "-DMY_HOME=$CTAKES_HOME" $LOG4J_PARM -Xms512M -Xmx3g $PIPE_RUNNER -p $name
    }    
    
    LogWrite "Starting pipeline $_"
    Start-Job $ScriptBlock -ArgumentList $_, $env:CTAKES_HOME, $CLASS_PATH, $LOG4J_PARM, $PIPE_RUNNER, $LogWriteDef, $logpath, $logtoconsole
}

if ($(Get-Job -State Failed | measure).Count -gt 0) {
    LogWrite "Error: Failed to initalize at least one pipeline; aborting all jobs."
    Get-Job | Stop-Job
    Get-Jon | Remove-Job
    exit 1
} else {
    LogWrite "All pipelines initialized."
}

# Check for successful initialization of all jobs; want to throw warning early on.
if ($initcheck) {
	Start-Sleep 30 # set sleep to empirically appropriate time. This should be quick now since main query done above.

	$runningjobs = $(Get-Job -State Running | measure).Count

	if ($runningjobs -lt $threads) {
		LogWrite "Warning: Only $runningjobs CPEs out of $threads were initialized successfully; check for problems."
	}
}

# Wait for it all to complete
While (Get-Job -State "Running")
{
    Start-Sleep 300
    $runningjobs = $(Get-Job -State Running | measure).Count
    $completedjobs = $(Get-Job -State Completed | measure).Count
    $failedjobs = $(Get-Job -State Failed | measure).Count
    $stoppedjobs = $(Get-Job -State Stopped | measure).Count
    LogWrite "Status: $runningjobs jobs are still running. $completedjobs jobs have completed. $failedjobs jobs have failed. $stoppedjobs jobs have stopped."
}

if ($completedjobs -eq $threads) {
    LogWrite "All CPEs have finished."
} else {
#    $date = (Get-Date).toString("yyyyMMdd")
#    $errorlog = $env:CTAKES_HOME+"\logs\"+$date+"_errors.log"
#    LogWrite "All CPEs have ceased running, but not all completed. Writing out failed job logs at $errorlog."
    LogWrite "All CPEs have ceased running, but not all completed."
#    Get-Job -State Failed | Receive-Job | Write-Output $errorlog
#
} ###FIX if using this block, want to allow user to set log level and option to write to file, console or not at all. Will need to create several versions of log4j.xml for each case.

Get-Job | Remove-Job

# Check if all documents have been completed; this may not be the case if any threads terminated early. If not, exit with error.

$query = "
SELECT COUNT(*)
FROM rptg.[{0}]
WHERE instance_id NOT IN (
	SELECT instance_id
	FROM dbo.document
	WHERE analysis_batch = {1})
" -f $idTable,$analysisBatch

$sqlcnt = Invoke-Sqlcmd -Query $query -ServerInstance "localhost" -Database "TREC" -QueryTimeout 60
$cnt = $sqlcnt.Column1

If ($cnt -gt 0) {
    $toWrite = "Not all documents were written to document table: " + $cnt + " documents remain unprocessed."
	LogWrite $toWrite
	LogWrite "#-------------------------------------------------------------------------------------------------#"
    exit 1
} ElseIf ($cnt -eq 0) {
    $toWrite = "All documents were written to document table. Job complete."
	LogWrite $toWrite
	LogWrite "#-------------------------------------------------------------------------------------------------#"
	exit 0
}
