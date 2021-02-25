
#Set source path
$SOURCE_PATH = "/Users/julian/IdeaProjects/powershell/files"
#Set kda path
$KDA_PATH = "/Users/julian/IdeaProjects/powershell/kda"
#Set project folder
$PROJECT_PATH = "/Users/julian/IdeaProjects/powershell/project"
#Move working directory to source path
Set-Location -Path $SOURCE_PATH
#For every file/folder in current path do ...

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
                    Write-Host $_.FullName "is File"
                    $PARENT_PATH = (get-item $_.FullName).Directory
                    Write-Host "Parent is" $PARENT_PATH.Name
                    $XXX = isKda($PARENT_PATH.Name)
                    Write-Host "IS KDA" $XXX

                    if (isProject($PARENT_PATH.Name)) {
                        $EXISTS_PROJECT_FOLDER = $PROJECT_PATH + "/" + $PARENT_PATH.Name
                        if (Test-Path $EXISTS_PROJECT_FOLDER) {

                        } else {
                            Write-Host "Create" $PROJECT_PATH "/" $PARENT_PATH.Name
                            New-Item -ItemType Directory -Force -Path ($PROJECT_PATH + "/" + $PARENT_PATH.Name) | Out-Null
                        }
                        $DEST = $PROJECT_PATH + "/" + $PARENT_PATH.Name

                        $num = 1
                        $nextname = ($DEST + "/" + $_.Name)
                        while(Test-Path $nextname) {
                            $nextName = Join-Path ($DEST + "/") ($_.BaseName + "_$num" + $_.Extension)
                            $num+=1
                        }
                        Move-Item $_.FullName -dest $nextname
                    }
                    elseif (isKda($PARENT_PATH.Name)) {
                       $EXISTS_KDA_FOLDER = $KDA_PATH + "/" + $PARENT_PATH.Name
                    if (Test-Path $EXISTS_KDA_FOLDER) {
                        Write-Host "Path" EXISTS_KDA_FOLDER " exists"
                    } else {
                        Write-Host "Create" $KDA_PATH "/" $PARENT_PATH.Name
                        New-Item -ItemType Directory -Force -Path ($KDA_PATH + "/" + $PARENT_PATH.Name) | Out-Null
                    }
                    $DEST = $KDA_PATH + "/" + $PARENT_PATH.Name

                    $num = 1
                    $nextname = ($DEST + "/" + $_.Name)
                    while(Test-Path $nextname) {
                        $nextName = Join-Path ($DEST + "/") ($_.BaseName + "_$num" + $_.Extension)
                        $num+=1
                    }
                        Move-Item $_.FullName -dest $nextname
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
    Get-ChildItem $CURR_LOCATION -recurse |
            Foreach-Object {
                if ((Get-ChildItem $_.FullName | Measure-Object).Count -eq 0) {
                    Write-Host "Will remove" $_.FullName
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
                    Move-Item -Path ($SOURCE_PATH_RENAME + "/" + $_.Name) ($SOURCE_PATH_RENAME + "/" +  $Matches[0])
                } else {
                    Write-Host not found
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

                    $NEW_TRUNCATED_NAME = $_.BaseName -replace ("(?<=(.{45})).+","")
                    $NEW_TRUNCATED_NAME_WITH_EXTENSION = $NEW_TRUNCATED_NAME + $_.Extension

                    $DEST = $SOURCE_PATH_TRUNCATE + "/" + $PARENT_PATH.Name
                    $num1 = 1
                    $nextname1 = ($DEST + "/" + $NEW_TRUNCATED_NAME_WITH_EXTENSION)
                    while((Test-Path $nextname1)) {
                        $nextName1 = Join-Path ($DEST + "/") ($NEW_TRUNCATED_NAME + "_$num1" + $_.Extension)
                        $num1+=1
                    }
                    if ($NEW_TRUNCATED_NAME_WITH_EXTENSION -eq $_.Name) {
                        Move-Item -Path ($DEST + "/" + $_.Name) ($DEST + "/" + $NEW_TRUNCATED_NAME_WITH_EXTENSION)
                    } else {
                        Move-Item ($DEST + "/" + $_.Name) -dest $nextname1
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
#careBoutFoldersWithoutNumer($SOURCE_PATH)
#renameAllToNumerOnly($KDA_PATH)
#renameAllToNumerOnly($PROJECT_PATH)
truncateFileNames("/Users/julian/IdeaProjects/powershell/project/")
