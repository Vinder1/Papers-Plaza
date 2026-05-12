using Npgsql;
using System.Text.Json;

var connString = Environment.GetEnvironmentVariable("DB_CONNECTION_STRING") 
    ?? "Host=localhost;Database=queue_db;Username=postgres;Password=postgres";

using var dataSource = NpgsqlDataSource.Create(connString);
var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, __) => cts.Cancel();

var random = new Random();
int producedCount = 0;
var sw = System.Diagnostics.Stopwatch.StartNew();

await using var conn = dataSource.CreateConnection();
await conn.OpenAsync(cts.Token);

Console.WriteLine("🚀 Producer started. Press Ctrl+C to stop.");

while (!cts.Token.IsCancellationRequested)
{
    // 80% обычные (0), 20% критические (100)
    int priority = random.Next(100) < 20 ? 100 : 0;
    var payload = JsonSerializer.Serialize(new 
    { 
        Message = $"Task-{Interlocked.Increment(ref producedCount)}", 
        Type = priority == 100 ? "CRITICAL" : "NORMAL" 
    });

    await using var tran = await conn.BeginTransactionAsync(cts.Token);
    try
    {
        // Фиктивная бизнес-логика в той же транзакции
        await using var auditCmd = new NpgsqlCommand(
            "INSERT INTO business_audit (event_type) VALUES ('create_task')", conn, tran);
        await auditCmd.ExecuteNonQueryAsync(cts.Token);

        // Вставка задачи + сигнал воркерам
        await using var insertCmd = new NpgsqlCommand(
            "INSERT INTO tasks (payload, priority) VALUES (@payload, @priority); NOTIFY new_task;", 
            conn, tran);
        insertCmd.Parameters.AddWithValue("payload", payload);
        insertCmd.Parameters.AddWithValue("priority", priority);
        await insertCmd.ExecuteNonQueryAsync(cts.Token);

        await tran.CommitAsync(cts.Token);
    }
    catch
    {
        await tran.RollbackAsync(cts.Token);
        throw;
    }

    // Логирование каждые 1000 задач
    if (producedCount % 1000 == 0)
    {
        Console.WriteLine($"📦 Produced: {producedCount} | Rate: {producedCount / (sw.ElapsedMilliseconds / 1000.0):F1} tps");
    }

    // ~200-500 вставок в секунду (задержка 1-5мс)
    await Task.Delay(random.Next(1, 5), cts.Token);
}