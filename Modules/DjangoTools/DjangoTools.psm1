# Implement your module commands in this script.
function Set-DjangoTemplateStructure {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]
        $AppPath
    )

    begin {
        Write-Verbose -Message "Scafolding django templates and static folder structure..."
    }

    process {
        # Set the templates folder structure and initiate a base html file
        $app = Split-Path -Path $AppPath -Leaf
        New-Item -ItemType Directory -Path "$AppPath\templates\$app"

        # Create the base html file
        Copy-Item -Path D:\Venv\DevOps\files\base.html -Destination "$AppPath\templates\$app\"

        # Create static folder structure with subfolders for css, js and image files
        New-Item -ItemType Directory -Path "$AppPath\static\$app"
        $static_path = "$AppPath\static\$app"
        New-Item -ItemType Directory -Path "$static_path\css", "$static_path\js", "$static_path\images"

        # Crate main.css and main.js files
        $css_path = "$static_path\css"
        $js_path = "$static_path\js"
        New-Item -ItemType File -Path "$css_path\main.css"
        New-Item -ItemType File -Path "$js_path\main.js"
    }

    end {
        Write-Verbose -Message "Templates and Static file structure has been setup for app $app"
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
