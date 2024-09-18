# PowerShell Active Directory Script

Ce script PowerShell permet de créer des utilisateurs et des groupes dans Active Directory à partir de chaînes JSON ou de fichiers JSON.

## Fonctionnalités

- Création d'utilisateurs à partir d'une chaîne JSON ou d'un fichier JSON.
- Création de groupes à partir d'une chaîne JSON ou d'un fichier JSON.
- Validation des emails et des mots de passe.
- Journalisation des actions dans un fichier log.
- Gestion des erreurs avec des messages détaillés.

## Prérequis

- Module Active Directory installé.
- Accès administrateur à l'Active Directory.
- PowerShell 5.1 ou supérieur.

## Utilisation

### Paramètres disponibles :

- `-u` : Utilisateurs au format JSON sous forme de chaîne.
- `-g` : Groupes au format JSON sous forme de chaîne.
- `-ufile` : Chemin vers un fichier JSON contenant les utilisateurs.
- `-gfile` : Chemin vers un fichier JSON contenant les groupes.

### Exemples d'utilisation

#### Utilisation avec des chaînes JSON en ligne de commande

```powershell
.\script.ps1 -u '[{"Name": "John Doe", "SamAccountName": "jdoe", "UserPrincipalName": "jdoe@example.com", "Password": "P@ssw0rd123", "Group": "Sales"}]' -g '[{"Name": "Sales", "Description": "Sales Department Group"}]'
