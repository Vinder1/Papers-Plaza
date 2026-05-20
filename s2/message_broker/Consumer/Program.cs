using Npgsql;

var connString = Environment.GetEnvironmentVariable("DB_CONNECTION_STRING") 
    ?? "Host=localhost;Port=5444;Database=broker_db;Username=postgres;Password=postgres";
var workerId = $"worker-{Guid.NewGuid().ToString()[..8]}";

using var dataSource = NpgsqlDataSource.Create(connString);
var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, __) => cts.Cancel();

// Запуск фонового процесса очистки зависших задач
_ = Task.Run(async () =>
{
    while (!cts.Token.IsCancellationRequested)
    {
        await using var cleanupConn = dataSource.CreateConnection();
        await cleanupConn.OpenAsync(cts.Token);
        await using var cmd = new NpgsqlCommand(@"
            UPDATE tasks 
            SET status = 'ready', updated_at = NOW(), worker_id = NULL, error_message = 'Reset: stuck'
            WHERE status = 'running' AND updated_at < NOW() - INTERVAL '30 seconds'", cleanupConn);
        var reset = await cmd.ExecuteNonQueryAsync(cts.Token);
        if (reset > 0) Console.WriteLine($"🔄 Reset {reset} stuck tasks to Ready.");
        await Task.Delay(TimeSpan.FromSeconds(30), cts.Token);
    }
}, cts.Token);

// Основной цикл с LISTEN/NOTIFY + fallback polling
await using var listenConn = dataSource.CreateConnection();
await listenConn.OpenAsync(cts.Token);
await using var listenCmd = new NpgsqlCommand("LISTEN new_task;", listenConn);
await listenCmd.ExecuteNonQueryAsync(cts.Token);

var processedCount = 0;
var sw = System.Diagnostics.Stopwatch.StartNew();

Console.WriteLine($"🛠️ Worker {workerId} started. Waiting for tasks...");

while (!cts.Token.IsCancellationRequested)
{
    // Ждем уведомление или таймаут 500мс (защита от потери сигналов)
    await listenConn.WaitAsync(TimeSpan.FromMilliseconds(500), cts.Token);

    await ProcessNextAsync(dataSource, cts.Token);
}

async Task ProcessNextAsync(NpgsqlDataSource ds, CancellationToken ct)
{
    await using var conn = ds.CreateConnection();
    await conn.OpenAsync(ct);

    // Атомарный захват задачи
    const string claimSql = @"
        WITH picked AS (
            SELECT id FROM tasks
            WHERE status = 'ready' AND scheduled_at <= NOW()
            ORDER BY priority DESC, created_at ASC
            LIMIT 1 FOR UPDATE SKIP LOCKED
        )
        UPDATE tasks
        SET status = 'running', updated_at = NOW(), worker_id = @wid
        WHERE id = (SELECT id FROM picked)
        RETURNING id, payload, attempts, max_attempts;
    ";

    await using var cmd = new NpgsqlCommand(claimSql, conn);
    cmd.Parameters.AddWithValue("wid", workerId);
    await using var reader = await cmd.ExecuteReaderAsync(ct);
    if (!await reader.ReadAsync(ct)) return;

    var taskId = reader.GetInt64(0);
    var payload = reader.GetString(1);
    var attempts = reader.GetInt32(2);
    var maxAttempts = reader.GetInt32(3);
    reader.Close();

    // Имитация обработки
    var processTime = Random.Shared.Next(50, 200);
    await Task.Delay(processTime, ct);

    // 10% шанс падения задачи
    bool isFail = Random.Shared.Next(100) < 10;
    
    await using var tran = await conn.BeginTransactionAsync(ct);
    try
    {
        if (isFail)
        {
            attempts++;
            if (attempts >= maxAttempts)
            {
                // DLQ
                await UpdateStatus(conn, tran, taskId, "failed", $"DLQ after {attempts} attempts");
            }
            else
            {
                // Exponential backoff: 5 * 2^(attempts-1) минут
                var delayMin = 5 * Math.Pow(2, attempts - 1);
                await using var retryCmd = new NpgsqlCommand(@"
                    UPDATE tasks SET status = 'ready', attempts = @att, 
                    scheduled_at = NOW() + (@delay * INTERVAL '1 minute'), 
                    updated_at = NOW(), error_message = 'Retry scheduled'
                    WHERE id = @id", conn, tran);
                retryCmd.Parameters.AddWithValue("att", attempts);
                retryCmd.Parameters.AddWithValue("delay", delayMin);
                retryCmd.Parameters.AddWithValue("id", taskId);
                await retryCmd.ExecuteNonQueryAsync(ct);
            }
        }
        else
        {
            await UpdateStatus(conn, tran, taskId, "completed", null);
            Interlocked.Increment(ref processedCount);
        }
        await tran.CommitAsync(ct);
    }
    catch
    {
        await tran.RollbackAsync(ct);
    }

    if (processedCount % 500 == 0)
    {
        Console.WriteLine($"✅ Worker {workerId} | Processed: {processedCount} | TPS: {processedCount / (sw.ElapsedMilliseconds / 1000.0):F1}");
    }
}

async Task UpdateStatus(NpgsqlConnection conn, NpgsqlTransaction tran, long id, string status, string? error)
{
    await using var cmd = new NpgsqlCommand(
        "UPDATE tasks SET status = @status, updated_at = NOW(), error_message = @err WHERE id = @id", conn, tran);
    cmd.Parameters.AddWithValue("status", status);
    cmd.Parameters.AddWithValue("err", (object?)error ?? DBNull.Value);
    cmd.Parameters.AddWithValue("id", id);
    await cmd.ExecuteNonQueryAsync();
}