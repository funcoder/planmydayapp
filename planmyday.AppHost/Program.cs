var builder = DistributedApplication.CreateBuilder(args);

var apiService = builder.AddProject<Projects.planmyday_ApiService>("apiservice");

builder.AddProject<Projects.planmyday_Web>("webfrontend")
    .WithExternalHttpEndpoints()
    .WithReference(apiService)
    .WaitFor(apiService);

builder.Build().Run();
