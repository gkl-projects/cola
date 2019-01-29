
@echo off
set currentPath=%~dp0
set mydump_file=%currentPath%mydb_dump-%date:~10,4%%date:~7,2%%date:~4,2%_%time:~0,2%%time:~3,2%.sql
:: 
::  This script is to start and configure the database server.
:: 
echo "Starting to insall the mysql as a service in the windows "
echo "The current path %currentPath%mysql-5.5.29-win32\ "

:: Trying to stop the service, incase of changing the installtion path.
sc stop MySQL

:: Kill the process related to the srvice.
for /f "tokens=2 delims=[:]" %%f in ('sc queryex MySQL ^|find /i "PID"') do set PID=%%f
taskkill /f /pid %PID%

:: wait 5 sec
ping 127.0.0.1 -n 10 > nul
:: Delete the service.
sc delete MySQL

:: wait 5 sec
ping 127.0.0.1 -n 10 > nul
:: Creating the service with autostart 
sc create MySQL start= auto DisplayName= MySQL binPath= "%currentPath%mysql-5.5.29-win32\bin\mysqld.exe --defaults-file=\"%currentPath%my.ini\" MySQL"

call "%currentPath%mysql-5.5.29-win32\bin\mysqld.exe" --install
echo "Starting the MySQL server."
call "%currentPath%mysql-5.5.29-win32\bin\mysqld.exe"
:: Start the servie
sc start MySQL

:: wait 5 sec
ping 127.0.0.1 -n 10 > nul

:: Check if we should create or migrate

IF EXIST "%currentPath%mysql-5.5.29-win32\data\mydb" (
echo "Migrate me."
echo "dummping the database to %mydump_file% "
call "%currentPath%mysql-5.5.29-win32\bin\mysqldump.exe" -u root --password="password" mydb --default-character-set=utf8 > "%mydump_file%"
call "%currentPath%mysql-5.5.29-win32\bin\mysql.exe" -u root --password="password" --default-character-set=utf8 < "%currentPath%/migration.sql">c:/migrate.log
) ELSE (
:: Creating the schema
echo "Creating the schema."
call "%currentPath%mysql-5.5.29-win32\bin\mysql.exe" -u root --password="password" --default-character-set=utf8 < "%currentPath%/mydb.sql">c:\create.log

)
echo "Done!!"
:: echo "Press any key to exit ..."
:: pause > nul

@echo on
