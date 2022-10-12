' **********************************************************************
'  Ce script permet d'exporter des databases MySQL au format sql gzippé.
'  Régis TEDONE <regis.tedone@gmail.com> SYRADEV©2022
' **********************************************************************

' Déclaration de variables pour stocker les infos de connexion à la database
Dim user, password
' Déclaration du chemin global de sauvegarde des databases
Dim chemin
' Déclaration des databases à ne pas exporter
Dim dbStopList

user = "root"
password = "Your_Password"
chemin = "C:\saveMysql\"
dbStopList = "Database mysql information_schema phpmyadmin performance_schema test"


' Plus rien à modifier à partir d'ici----------------------------------------------------------------------

' Fonction qui teste si un programme est actif
Function appRunning(app)
    Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
    Set colProcessList = objWMIService.ExecQuery ("Select Name from Win32_Process WHERE Name LIKE '" & app & "%'")
    appRunning = colProcessList.count>0
    Set objWMIService = Nothing
    Set colProcessList = Nothing    
End Function

' On récupère la date au format Annee-Mois-Jour
Dim date, dateFormatted
date = Now
dateFormatted = Year(date) & "-" & Month(date) & "-" & Day(date) 

' On déclare et initialise un objet de type File System Object pour créer les dossiers
Dim ObjFso
Set ObjFso = CreateObject("Scripting.FileSystemObject")


' On créé le dossier principal s'il n'existe pas
if not ObjFso.FolderExists(chemin) Then
    ObjFso.CreateFolder(chemin)
End If

' On ajoute le dossier daté au chemin
chemin = chemin & dateFormatted & "\"

' On créé le dossier daté s'il n'existe pas
if not ObjFso.FolderExists(chemin) Then
    ObjFso.CreateFolder(chemin)
End If

' Déclararation d'une variable qui sera un objet WScript.Shell
Dim ObjShell
' On initialise l'objet Shell
Set ObjShell = WScript.CreateObject("WScript.Shell")


' On déclare et initialise une variable qui va contenir la commande de récupération du nom des databases à exporter 
Dim listDbCmd
listDbCmd = "cmd /c mysql --user=" & user & " -p" & password & " -e ""SHOW DATABASES;""  | findstr -Ev """ & dbStopList & """"

' On récupère la liste des databases à exporter
set listDb = ObjShell.Exec(listDbCmd)

' Démarrage de MySQL s'il est arrêté, la fonction appRunning est définie plus haut
if not appRunning("mysqld") Then
    ObjShell.Run("mysqld")
End If

' On déclare une variable qui stockera la commande d'export SQL avec le binaire mysqldump.exe
Dim dbExportCmd

' On déclare une variable pour compter les databases
Dim dbCount
dbCount = 0

' On récupèrera le nom des databses pour le message final
Dim dataBases

' On exporte les databases au format SQL
Do
    dbCount = dbCount+1
    ' On parcourt la liste des databases ligne par ligne
    db = listDb.StdOut.ReadLine
    ' On récupère le nom de la database pour le message final
    dataBases = dataBases & "- " &  db & VbCrLf
    ' On exporte un fichier sql gzippé
    dbExportCmd = "cmd /c  mysqldump --force --user=" & user & "  --password=" & password & " --add-drop-database --databases " & db & " |gzip> " & chemin & db & ".sql.gz"
    ObjShell.Run(dbExportCmd)
Loop While Not listDb.Stdout.atEndOfStream

' On affiche le message de confirmation de création des exports
Dim message
message = "   ____                     ___" & VbCrLf & "  / __/_ _________ _/_  \___ _  __" & VbCrLf & " _\ \/ // / __/  _  `/  //  /  -_)   |/ /" & vbCrLf & "/___/\_, /_/  \_,_/____/\__/|___/" & VbCrLf & "     /___/" & VbCrLf & VbCrLf
message = message & dbCount & " Databases sauvegardees dans " & chemin & VbCrLf & dataBases

' On affiche le message final
Msgbox message, vbInformation, "Export automatique MySQL ;-)"
