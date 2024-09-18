# Importe le module Active Directory
Import-Module ActiveDirectory

# Fonction pour créer un utilisateur
function New-ADUserFromJSON {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$Users
    )

    foreach ($user in $Users) {
        # Validation de l'email
        if (-not $user.UserPrincipalName -match "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
            Log-Message -Message "Email invalide pour l'utilisateur: $($user.Name)" -Type "Error"
            continue
        }

        # Validation du mot de passe
        if ($user.Password.Length -lt 8) {
            Log-Message -Message "Le mot de passe de l'utilisateur $($user.Name) doit contenir au moins 8 caractères." -Type "Error"
            continue
        }

        $securePassword = ConvertTo-SecureString $user.Password -AsPlainText -Force

        # Vérifier si l'utilisateur existe déjà
        if (-not (Get-ADUser -Filter {SamAccountName -eq $user.SamAccountName} -ErrorAction SilentlyContinue)) {
            New-ADUser -Name $user.Name `
                       -SamAccountName $user.SamAccountName `
                       -UserPrincipalName $user.UserPrincipalName `
                       -AccountPassword $securePassword `
                       -Enabled $true `
                       -Path ($user.OU -or "OU=Users,DC=example,DC=com")

            Log-Message -Message "Utilisateur $($user.Name) créé avec succès." -Type "Info"

            # Ajouter l'utilisateur au groupe s'il est spécifié
            if ($user.Group) {
                Add-ADGroupMember -Identity $user.Group -Members $user.SamAccountName
                Log-Message -Message "Utilisateur $($user.Name) ajouté au groupe $($user.Group)." -Type "Info"
            }
        } else {
            Log-Message -Message "Utilisateur $($user.Name) existe déjà." -Type "Warning"
        }
    }
}

# Fonction pour créer un groupe
function New-ADGroupFromJSON {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$Groups
    )

    foreach ($group in $Groups) {
        # Vérifier si le groupe existe déjà
        if (-not (Get-ADGroup -Filter {Name -eq $group.Name} -ErrorAction SilentlyContinue)) {
            New-ADGroup -Name $group.Name `
                        -Description $group.Description `
                        -GroupScope Global `
                        -Path ($group.OU -or "OU=Groups,DC=example,DC=com")

            Log-Message -Message "Groupe $($group.Name) créé avec succès." -Type "Info"
        } else {
            Log-Message -Message "Groupe $($group.Name) existe déjà." -Type "Warning"
        }
    }
}

# Fonction de log
function Log-Message {
    param (
        [string]$Message,
        [string]$Type
    )

    $logFilePath = "C:\ADScriptLogs\ad_script_log.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"

    # Créer le répertoire de logs si nécessaire
    if (-not (Test-Path -Path "C:\ADScriptLogs")) {
        New-Item -ItemType Directory -Path "C:\ADScriptLogs"
    }

    Add-Content -Path $logFilePath -Value $logMessage
}

# Traitement des entrées JSON ou fichier JSON
param (
    [string]$u,
    [string]$g,
    [string]$ufile,
    [string]$gfile
)

# Chargement des utilisateurs depuis le JSON ou le fichier
if ($u) {
    $users = $u | ConvertFrom-Json
    New-ADUserFromJSON -Users $users
} elseif ($ufile) {
    $users = Get-Content -Path $ufile | ConvertFrom-Json
    New-ADUserFromJSON -Users $users
}

# Chargement des groupes depuis le JSON ou le fichier
if ($g) {
    $groups = $g | ConvertFrom-Json
    New-ADGroupFromJSON -Groups $groups
} elseif ($gfile) {
    $groups = Get-Content -Path $gfile | ConvertFrom-Json
    New-ADGroupFromJSON -Groups $groups
}
