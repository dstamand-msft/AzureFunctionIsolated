using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace AZFuncIsolatedAppInsights
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var host = new HostBuilder()
                .ConfigureFunctionsWorkerDefaults()
                .ConfigureLogging((context, builder) =>
                {
                    // does not work as per https://github.com/Azure/azure-functions-dotnet-worker/issues/423
                    //builder.AddApplicationInsights();

                    var applicationInsightsConnectionString = context.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"];
                    if (!string.IsNullOrEmpty(applicationInsightsConnectionString))
                    {
                        builder.AddApplicationInsights(configureTelemetryConfiguration =>
                        {
                            configureTelemetryConfiguration.ConnectionString = applicationInsightsConnectionString;
                        }, _ => { });
                    }

                    builder.SetMinimumLevel(LogLevel.Trace);
                })
                .Build();

            await host.RunAsync();
        }
    }
}
