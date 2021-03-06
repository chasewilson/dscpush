#Fill in the values below and save to your content store.

#region Node Definition: Master
$Master = New-Node -Name 'Master' -NodeId '1883264f-9536-4466-a81c-77d8fbfec315' -Type 'DscPushMasterNode'

#region Target Config: DscPushAD
$DscPushAD = New-TargetConfig -Properties @{
    ConfigName = 'DscPushAD'
    ContentHost = $False
    RoleList = @(
        "OsCore"
        "DomainController"
        "HardenWinServer"
    )
}
$DscPushADAdapterProperties = @{
    InterfaceAlias = 'Ethernet'
    NetworkAddress = '192.0.0.245'
    SubnetBits     = '24'
    DnsAddress     = '192.0.0.245'
    AddressFamily  = 'IPv4'
    Description    = ''
}
$DscPushAD.TargetAdapter = New-TargetAdapter @DscPushADAdapterProperties
$DscPushAD.Variables += @{
    ComputerName='DC'
    ContentStore='\\CH\C$\ContentStore'
    DomainCredential='|pscredential|'
    DomainName='DscPush.local'
    JoinDomain='false'
    NetworkConfig='[
    {`
        "SubnetBitMask":  24,
        "NetworkCategory":  "DomainAuthenticated",
        "Alias":  "Ethernet",
        "IPAddress":  "192.0.0.245",
        "DNSServer":  "192.0.0.245"
    }
]'
}
$Master.Configs += $DscPushAD
#endregion Target Config: DscPushAD

#region Target Config: DscPushCH
$DscPushCH = New-TargetConfig -Properties @{
    ConfigName = 'DscPushCH'
    ContentHost = $True
    ContentStorePath = ''
    RoleList = @(
        "OsCore"
        "HardenWinServer"
    )
}
$DscPushCHAdapterProperties = @{
    InterfaceAlias = 'Ethernet'
    NetworkAddress = '192.0.0.246'
    SubnetBits     = '24'
    DnsAddress     = '192.0.0.245'
    AddressFamily  = 'IPv4'
    Description    = ''
}
$DscPushCH.TargetAdapter = New-TargetAdapter @DscPushCHAdapterProperties
$DscPushCH.Variables += @{
    ComputerName='CH'
    ContentStore='C:\ContentStore'
    DomainCredential='|pscredential|'
    DomainName='DscPush.local'
    JoinDomain='true'
    NetworkConfig='[
    {
        "SubnetBitMask":  24,
        "NetworkCategory":  "DomainAuthenticated",
        "Alias":  "Ethernet",
        "IPAddress":  "192.0.0.246",
        "DNSServer":  "192.0.0.245"
    }
]'
}
$Master.Configs += $DscPushCH
#endregion Target Config: DscPushCH

#endregion Node Definition: Master


@($Master)
