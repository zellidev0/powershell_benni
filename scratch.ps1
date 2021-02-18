
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
    $DIR -match '.*\d\d-0\d\d\d\d[a-zA-Z].*'
}

function isKda {
    param (
        $DIR
    )
    $DIR -match '.*\d\d-\d\d\d\d\d[a-zA-Z].*'
}

function moveNestedFoldersToTop {
    param (
        $SOURCE_PATH
    )
    Get-ChildItem $SOURCE_PATH |
            Foreach-Object {
                $IS_DIR = Test-Path -Path $_.FullName -PathType Container
                $IS_FILE = Test-Path -Path $_.FullName -PathType Leaf
                if ($IS_DIR) {
                    moveNestedFoldersToTop($_.FullName)
                } else {
                    "Current File is " + $_.Name
                    $DEST = $KDA_PATH + "/" + $_.Name
                    if (Test-Path $DEST) {
                        Move-Item $_.FullName -dest ($DEST + "/" + $_.Name)

                        # remove the now empty folder where we moved all child elements
                        Remove-Item $DEST -Force
                    } else {
                        Move-Item $_.FullName -dest $DEST
                    }
                }

                $path = $_.FullName
                $IS_DIR = ((Get-Item $_.FullName) -is [System.IO.DirectoryInfo])
                if (isKda($path) -And $IS_DIR) {
                    "Found folder "+ $path
                    $DEST = $KDA_PATH + "/" + $_.Name
                    if (Test-Path $DEST) {
                        $CHILD_FILES = Get-ChildItem $_.FullName
                        # do for all child elements
                        $CHILD_FILES | Foreach-Object {
                            Move-Item $_.FullName -dest ($DEST + "/" + $_.Name)
                        }
                        # remove the now empty folder where we moved all child elements
                        Remove-Item $DEST -Force
                    } else {
                        Move-Item $_.FullName -dest $DEST
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

#doForEveryFolder
moveNestedFoldersToTop($SOURCE_PATH)
#$XXX = "BHXJS22-22222HYVTG" -replace '[^(\d{2}-\d\d\d\d\d)]' , ''
#$XXX = Select-String -Pattern "\d{2}-\d\d\d\d\d" -InputObject "BHXJS22-22222HYVTG"
#
#
#The quick and dirty:

