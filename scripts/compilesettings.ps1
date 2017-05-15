param([boolean]$reverse=$false, [Parameter(Mandatory=$true)][string]$placeholders="", [string]$outputfile="", [boolean]$detailed=$false, [string]$modulepath="")
# UG-in-a-box Citrix NetScaler automation helper and conversion script
# (c) Thorsten Rood 12.05.2017 v1.17 thorsten@rood.cc
# freeware license

if (($outputfile -eq "") -and ($detailed -eq $false)) {
	Write-Host "you need to specify either outputfile or detailed mode"
	Write-Host "aborted"
	break
}

[Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
if (Test-Path $placeholders) {
	$variables = get-content -path $placeholders
	if ($outputfile -ne "") {
		if (Test-Path $outputfile) {
			Remove-Item $outputfile
		}
		$unixfilefullbatch = New-Object System.IO.StreamWriter ($outputfile, $false)
		Write-Host "creating flat output file " -NoNewLine
		Write-Host $outputfile
	}
	else {
		$unixfilefullbatch = $null
	}
	if ($modulepath -eq "") {
		$modulepath = "."
	}
	Write-Host "scanning .conf files in directory " -NoNewLine
	Write-Host $modulepath
	$files = Get-ChildItem $modulepath -filter "*.conf" -file | Sort -Property name | Select name
	foreach ($file in $files) {
		$content = get-content -path ($modulepath + "\" + $file.Name)
		Write-Host "...compiling " -NoNewLine
		Write-Host $file.Name
		$file = ($modulepath + "\" + $file.Name + ".patched")
		$contentNew = ""
		foreach ($line in $content) {
			foreach ($variable in $variables) {
				$searchReplace = $variable.Split(",", 2, [System.StringSplitOptions]::RemoveEmptyEntries)
				if ($reverse) {
					$line = $line -creplace $searchReplace[1], $searchReplace[0]
				}
				else {
					$line = $line -creplace $searchReplace
				}
			}
			$contentNew = $contentNew + $line + "`n"
		}
		if ($detailed) {
			if (Test-Path $file) {
				Remove-Item $file
			}
			$unixfile = New-Object System.IO.StreamWriter ($file, $false)
			$unixfile.Write($contentNew)
			$unixfile.Flush()
			$unixfile.Close()
		}
		if ($unixfilefullbatch) {
			$unixfilefullbatch.Write($contentNew)
		}
	}
	if ($unixfilefullbatch) {
		$unixfilefullbatch.Flush()
		$unixfilefullbatch.Close()
	}
	Write-Host "finished"
}
