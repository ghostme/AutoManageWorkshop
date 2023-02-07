Configuration SoftwareInstallation {

    Import-DscResource -ModuleName 'PSDscResources'

    Node localhost {
        MsiPackage PowerShell {
            Ensure = 'Present'
            Path = 'https://github.com/PowerShell/PowerShell/releases/download/v7.3.2/PowerShell-7.3.2-win-x64.msi'
            ProductId = '{323AD147-6FC4-40CB-A810-2AADF26D868A}'
            Arguments = '/quiet /norestart'
        }
    }
}

SoftwareInstallation