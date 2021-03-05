
#Make sure these folders exists
$SOURCE_PATH = "/Users/julian/IdeaProjects/powershell/files"
$KDA_PATH = "/Users/julian/IdeaProjects/powershell/kda"
$KDA_ONE_CHILD_PATH = "/Users/julian/IdeaProjects/powershell/kda_one_child"
$PROJECT_PATH = "/Users/julian/IdeaProjects/powershell/project"
$PROJECT_ONE_CHILD_PATH = "/Users/julian/IdeaProjects/powershell/project_one_child"
#Make sure these files exist
$LOG_FILE_PATH = "/Users/julian/IdeaProjects/powershell/logfile.txt"
$RENAMED_LOGS_CSV_PATH = "/Users/julian/IdeaProjects/powershell/log_renaming.csv"


Set-Location -Path $SOURCE_PATH

function isProject {
    param (
        $DIR
    )
    $DIR -match '.*\d\d-0\d\d\d\d[^0-9]?.*'
}

function isKda {
    param (
        $DIR
    )
    $DIR -match '.*\d\d-\d\d\d\d\d[^0-9]?.*'
}

function moveNestedFoldersToTop {
    param (
        $SOURCE_PATH
    )
    Get-ChildItem $SOURCE_PATH  -recurse |
            Foreach-Object {
#               Write-Host $_.FullName
#               $IS_DIR = Test-Path -Path $_.Parent -PathType Container
                $IS_FILE = Test-Path -Path $_.FullName -PathType Leaf
                if ($IS_FILE) {
                    $PARENT_PATH = (get-item $_.FullName).Directory
                    $XXX = isKda($PARENT_PATH.Name)

                    if (isProject($PARENT_PATH.Name)) {
                        $EXISTS_PROJECT_FOLDER = $PROJECT_PATH + "/" + $PARENT_PATH.Name
                        if (Test-Path $EXISTS_PROJECT_FOLDER) {

                        } else {
                            $LogValue = 'Created "' + $PROJECT_PATH + '/' + $PARENT_PATH.Name + '"'
                            Add-Content -Path $LOG_FILE_PATH -Value $LogValue
                            Write-Host $LogValue
                            New-Item -ItemType Directory -Force -Path ($PROJECT_PATH + "/" + $PARENT_PATH.Name) | Out-Null
                        }
                        $DEST = $PROJECT_PATH + "/" + $PARENT_PATH.Name

                        $num = 1
                        $nextname = ($DEST + "/" + $_.Name)
                        while(Test-Path $nextname) {
                            $nextName = Join-Path ($DEST + "/") ($_.BaseName + "_$num" + $_.Extension)
                            $num+=1
                        }
                        $LogValue = 'Moved "' + $_.FullName + '" to "' + $nextname + '"'
                        Add-Content -Path $LOG_FILE_PATH -Value $LogValue
                        Write-Host $LogValue
                        New-Item -ItemType Directory -Force -Path ($PROJECT_PATH + "/" + $PARENT_PATH.Name) | Out-Null
                        Move-Item $_.FullName -dest $nextname
                    }
                    elseif (isKda($PARENT_PATH.Name)) {
                        $EXISTS_KDA_FOLDER = $KDA_PATH + "/" + $PARENT_PATH.Name
                        if (Test-Path $EXISTS_KDA_FOLDER) {

                        } else {
                            $LogValue = 'Created "' + $KDA_PATH + '/' + $PARENT_PATH.Name + '"'
                            Add-Content -Path $LOG_FILE_PATH -Value $LogValue
                            Write-Host $LogValue
                            New-Item -ItemType Directory -Force -Path ($KDA_PATH + "/" + $PARENT_PATH.Name) | Out-Null
                        }
                        $DEST = $KDA_PATH + "/" + $PARENT_PATH.Name

                        $num = 1
                        $nextname = ($DEST + "/" + $_.Name)
                        while(Test-Path $nextname) {
                            $nextName = Join-Path ($DEST + "/") ($_.BaseName + "_$num" + $_.Extension)
                            $num+=1
                        }
                        $LogValue = 'Moved "' + $_.FullName + '" to "' + $nextname + '"'
                        Add-Content -Path $LOG_FILE_PATH -Value $LogValue
                        Write-Host $LogValue
                        Move-Item $_.FullName -dest $nextname
                    }
                }
            }
}




function moveNonKDAandProjectFilesOneFolderUp {
    param (
        $SOURCE_PATH
    )
    Get-ChildItem $SOURCE_PATH  -recurse |
            Foreach-Object {
                $IS_FILE = Test-Path -Path $_.FullName -PathType Leaf
                if ($IS_FILE) {
                    $PARENT_PATH = (get-item $_.FullName).Directory

                    if (isProject($PARENT_PATH.Name)) {

                    }
                    elseif (isKda($PARENT_PATH.Name)) {

                    } else {
                        if (isKda($PARENT_PATH)) {
                            $PARENT = (get-item $_.FullName).Directory
                            Write-host $PARENT
                            Write-host $PARENT.Name
                            Move-Item $_.FullName -dest ($PARENT.Parent.FullName + "/" + ($PARENT.Name) + $_.Name)
                        } elseif (isProject($PARENT_PATH)) {
                            $PARENT = (get-item $_.FullName).Directory
                            Write-host $PARENT
                            Write-host $PARENT.Name
                            Move-Item $_.FullName -dest ($PARENT.Parent.FullName + "/" + ($PARENT.Name) + $_.Name)
                        } else {

                        }
                    }
                }
            }
}

# A script block (anonymous function) that will remove empty folders
# under a root folder, using tail-recursion to ensure that it only
# walks the folder tree once. -Force is used to be able to process
# hidden files/folders as well.
function removeEmptyFolders {
    param(
        $Path
    )
    Get-ChildItem $Path -recurse |
            Foreach-Object {
                if ((Get-ChildItem $_.FullName | Measure-Object).Count -eq 0) {
                    $LogValue = 'Removed empty folder"' +  $_.FullName + '"'
                    Add-Content -Path $LOG_FILE_PATH -Value $LogValue
                    Write-Host $LogValue
                    Remove-Item $_.FullName -Force -Recurse
                }
            }
}

function renameAllToNumerOnly {
    param(
        $SOURCE_PATH_RENAME
    )
    Get-ChildItem $SOURCE_PATH_RENAME |
            Foreach-Object {
                $RESULT = $_.Name -match '\d\d-\d\d\d\d\d'
                if ($RESULT) {
                    $FROM = ($SOURCE_PATH_RENAME + "/" + $_.Name)
                    $TO = ($SOURCE_PATH_RENAME + "/" + $Matches[0])
                    if ($FROM -eq $TO) {

                    } else {
                        if (Test-Path $TO) {
                            Move-Item -Path ($FROM + "/*" ) $TO
                            $LogValue = 'Moved all from "' + $FROM +'" to "' + $TO + '"'
                            Add-Content -Path $LOG_FILE_PATH -Value $LogValue
                            Write-Host $LogValue
                            Remove-Item -Path $FROM
                        } else {
                            $LogValue = 'Renamed "' + $FROM +'" to "' + $TO + '"'
                            Add-Content -Path $LOG_FILE_PATH -Value $LogValue
                            $RENAMEVALUELOG = $_.Name + ',' + $Matches[0] + ';'
                            Add-Content -Path $RENAMED_LOGS_CSV_PATH -Value $RENAMEVALUELOG
                            Write-Host $LogValue
                            Move-Item -Path $FROM $TO
                        }
                    }
                } else {
                    Write-Host not found $RESULT
                }
            }
}

function removeAllImages {
    param(
        $SOURCE_PATH_RENAME
    )
    Get-ChildItem $SOURCE_PATH_RENAME -recurse|
            Foreach-Object {
                if (($_.Extension -eq ".jpg") -or
                        ($_.Extension -eq ".JPG") -or
                        ($_.Extension -eq ".jpeg") -or
                        ($_.Extension -eq ".JPEG") -or
                        ($_.Extension -eq ".png") -or
                        ($_.Extension -eq ".PNG")) {
                    $LogValue = 'Removed "' + $_.FullName + '"'
                    Add-Content -Path $LOG_FILE_PATH -Value $LogValue
                    Write-Host $LogValue
                    Remove-Item -Path $_.FullName
                }
            }
}

function removeAllNonImages {
    param(
        $SOURCE_PATH_RENAME
    )
    Get-ChildItem $SOURCE_PATH_RENAME -recurse|
            Foreach-Object {
                if (Test-Path -Path $_.FullName -PathType Leaf) {
                    if (($_.Extension -eq ".jpg") -or
                            ($_.Extension -eq ".JPG") -or
                            ($_.Extension -eq ".jpeg") -or
                            ($_.Extension -eq ".JPEG") -or
                            ($_.Extension -eq ".png") -or
                            ($_.Extension -eq ".PNG")) {
                    } else {
                        $LogValue = 'Removed "' + $_.FullName + '"'
                        Add-Content -Path $LOG_FILE_PATH -Value $LogValue
                        Write-Host $LogValue
                        Remove-Item -Path $_.FullName
                    }
                }
            }
}

function moveFolderWithOneChildToSeparate {
    param(
        $SOURCE_PATH_RENAME
    )

    Get-ChildItem $SOURCE_PATH_RENAME |
            Foreach-Object {
                $COUNT = (Get-ChildItem $_.FullName | Measure-Object ).Count
                if ($COUNT -eq 1) {
                    $LogValue = 'Moved because only one child element "' + $_.FullName + '"'
                    Add-Content -Path $LOG_FILE_PATH -Value $LogValue
                    Write-Host $LogValue
                    Move-Item -Path ($_.FullName) ($KDA_ONE_CHILD_PATH + "/" + $_.Name)
                }
            }
}

# stopps when the file with a given name already exists
function truncateFileNames {
    param(
        $SOURCE_PATH_TRUNCATE
    )
    Get-ChildItem $SOURCE_PATH_TRUNCATE -Recurse |
            Foreach-Object {
                if (Test-Path -Path $_.FullName -PathType Leaf) {
                    $PARENT_PATH = (get-item $_.FullName).Directory

                    $NEW_TRUNCATED_NAME = $_.BaseName -replace ("(?<=(.{42})).+","")
                    $NEW_TRUNCATED_NAME_WITH_EXTENSION = $NEW_TRUNCATED_NAME + $_.Extension
                    if ($_.BaseName.length -gt 44) {
                        $DEST1 = $SOURCE_PATH_TRUNCATE + "/" + $PARENT_PATH.Name
                        $num1 = 1
                        $nextname1 = ($DEST1 + "/" + $NEW_TRUNCATED_NAME_WITH_EXTENSION)
                        while((Test-Path $nextname1)) {
                            $nextName1 = Join-Path ($DEST1 + "/") ($NEW_TRUNCATED_NAME + "_$num1" + $_.Extension)
                            $num1+=1
                        }
                        $LogValue = 'Renamed "' + $DEST1 + "/" + $_.Name + '" to "' + $nextName1 + '"'
                        Add-Content -Path $LOG_FILE_PATH -Value $LogValue
                        Write-Host $LogValue
                        Move-Item ($DEST1 + "/" + $_.Name) -dest $nextname1
                    }
                }
            }
}




function doForEveryFolder {
    $CURR_LOCATION = Get-Location
    Get-ChildItem $CURR_LOCATION |
            Foreach-Object {
                $path = $_.FullName
                #if the file name matches e.g. ZZ-0ZZZZA
                if (isProject($path)) {
                    #else if the file name matches e.g. ZZ-ZZZZZZ
                } elseif (isKda($path)) {
                    #The folder in kda exists
                    if (Test-Path ($KDA_PATH + "/" + $_.Name)) {
                        Write-Host "Folder" $_.Name "exists in kda, copy children to it"
                        # store all child elements
                        $CHILD_FILES = Get-ChildItem $_.FullName
                        Write-Host "Moving children to ../kda/"$_.Name
                        # store the kda destination folder of the current one
                        $DEST = $KDA_PATH + "/" + $_.Name
                        # do for all child elements
                        $CHILD_FILES | Foreach-Object {
                            $num = 1
                            # store the destination path in kda of the child element
                            $nextName =  Join-Path $DEST $_.Name
                            Write-Host "Current child file is" $_.FullName
                            # if it already exists increment a number
                            while(Test-Path -Path $nextName) {
                                $nextName = Join-Path $DEST ($_.BaseName + "_$num" + $_.Extension)
                                Write-Host "File exists, try" $nextName
                                $num += 1
                            }
                            # does not exist with number and save it
                            Move-Item $_.FullName -dest $nextName
                            Write-Host "Saved file" $nextName
                        }
                        # remove the now empty folder where we moved all child elements
                        Remove-Item ($SOURCE_PATH + "/" + $_.Name) -Force -Recurse
                        #The folder does not exist in kda
                    } else {
                        Write-Host "FOUND KDA"
                        $RESULT = $_.Name -match '\d\d-\d\d\d\d\d'
                        if ($RESULT) {
                            Rename-Item -Path ($SOURCE_PATH + "/" + $_.Name) -NewName $Matches[0]
                            Write-Host "HELLOE"
                            Write-Host $Matches[0]
                            Move-Item ($SOURCE_PATH + "/" + $Matches[0]) ($KDA_PATH + "/" + $Matches[0])
                        }
                    }
                    #else the file matches none
                } else {
                    "matches not" + $_.Name
                }
            }

}

#moveNestedFoldersToTop($SOURCE_PATH)
#1..10 | % {
#    removeEmptyFolders($SOURCE_PATH)
#}
#moveNonKDAandProjectFilesOneFolderUp($SOURCE_PATH)
#removeEmptyFolders($SOURCE_PATH)
#Add-Content -Path $RENAMED_LOGS_CSV_PATH -Value "Old Name,New Name;"
#renameAllToNumerOnly($KDA_PATH)
#renameAllToNumerOnly($PROJECT_PATH)
#truncateFileNames($KDA_PATH)
#truncateFileNames($PROJECT_PATH)
#removeAllImages($KDA_PATH)
#removeAllImages($PROJECT_PATH)
#removeAllNonImages($KDA_PATH)
#removeAllNonImages($PROJECT_PATH)
#moveFolderWithOneChildToSeparate($KDA_PATH)
#moveFolderWithOneChildToSeparate($PROJECT_PATH)
