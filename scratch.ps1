
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
    $DIR -match '\d\d-0\d\d\d\d[a-zA-Z]'
}

function isKda {
    param (
        $DIR
    )
    $DIR -match '\d\d-0\d\d\d\d[a-zA-Z]'
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
                        $DEST = $KDA_PATH + "/" + $_.Name
                        Move-Item $_.FullName $DEST
                    }

                    #else the file matches none
                } else {
                    "matches not"
                }
            }

}

doForEveryFolder
