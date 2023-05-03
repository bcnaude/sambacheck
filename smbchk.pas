// Check from a Linux computer if a samba network share is active on another computer.
// Use FreePascal fpc to compile.

program CheckSambaNetworkShare;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, process;

var
  IP, useAuth, username, pwd, useDomain, domain, cmd, password: string;
  processObj: TProcess;
begin
  // Get computer password
  Write('Enter this computer''s password: ');
  Readln(password);
  WriteLn('=========================================================');
  WriteLn();

  // Check samba version
  cmd := 'echo ' + password + ' | sudo -S smbstatus';
  WriteLn('Checking samba version...');
  processObj := TProcess.Create(nil);
  try
    processObj.Executable := '/bin/sh';
    processObj.Parameters.Add('-c');
    processObj.Parameters.Add(cmd);
    processObj.Options := processObj.Options + [poWaitOnExit];
    processObj.Execute;
  finally
    processObj.Free;
  end;

  // Check samba status
  cmd := 'echo ' + password + ' | sudo -S systemctl status smbd';
  WriteLn('Checking samba status...');
  processObj := TProcess.Create(nil);
  try
    processObj.Executable := '/bin/sh';
    processObj.Parameters.Add('-c');
    processObj.Parameters.Add(cmd);
    processObj.Options := processObj.Options + [poWaitOnExit];
    processObj.Execute;
  finally
    processObj.Free;
  end;

  // Check if network share is active
  WriteLn('=========================================================');
  WriteLn();
  Write('IP where the Samba share resides: ');
  Readln(IP);
  Write('Does the share use user authentication (y/n): ');
  Readln(useAuth);

  if (useAuth = 'y') then
  begin
    Write('What is the username of the share: ');
    Readln(username);
    Write('What is the password of the share: ');
    Readln(pwd);
    Write('Are you using a domain (y/n): ');
    Readln(useDomain);

    if (useDomain = 'y') then
    begin
      Write('Enter the domain name: ');
      Readln(domain);
      cmd := 'echo ' + password + ' | sudo -S smbclient -L ' + IP + ' -U ' + domain + '\' + username + '%' + pwd;
    end
    else
    begin
      cmd := 'echo ' + password + ' | sudo -S smbclient -L ' + IP + ' -U ' + username + '%' + pwd;
    end;
  end
  else
  begin
    cmd := 'echo ' + password + ' | sudo -S smbclient -L ' + IP;
  end;

  processObj := TProcess.Create(nil);
  try
    processObj.Executable := '/bin/sh';
    processObj.Parameters.Add('-c');
    processObj.Parameters.Add(cmd);
    processObj.Options := processObj.Options + [poWaitOnExit];
    processObj.Execute;
  finally
    processObj.Free;
  end;

  WriteLn('Done.');
end.
