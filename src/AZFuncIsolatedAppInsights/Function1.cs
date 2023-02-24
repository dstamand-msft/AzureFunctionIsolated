using System;
using System.Collections.Generic;
using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace AZFuncIsolatedAppInsights
{
    public class Function1
    {
        private readonly ILogger _logger;

        public Function1(ILogger<Function1> logger)
        {
            _logger = logger;
        }

        [Function("Function1")]
        public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
        {
            var extraProperty = "Hello World!!";

            _logger.LogTrace("A trace log with an extra property {ExtraProperty}", extraProperty);
            _logger.LogDebug("A debug log with an extra property {ExtraProperty}", extraProperty);
            _logger.LogInformation("An information log with an extra property {ExtraProperty}", extraProperty);
            _logger.LogWarning("A warning log with an extra property {ExtraProperty}", extraProperty);
            _logger.LogError("An error log with an extra property {ExtraProperty}", extraProperty);

            var state = new Dictionary<string, object>
            {
                { "StateKey", "StateValue" },
                { "StateKey2", "StateValue2" },
                { "StateKey3", "StateValue3" }
            };

            using (_logger.BeginScope(state))
            {
                _logger.LogInformation("A log information with some states");
            }

            _logger.LogInformation("C# HTTP trigger function processed a request.");

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

            response.WriteString($"Welcome to Azure Functions! - Current date UTC: {DateTimeOffset.UtcNow:O}");

            return response;
        }
    }
}
