using System;
using System.IO;
using System.Threading.Tasks;
using Azure;
using Azure.AI.ContentSafety;
using Azure.Storage.Blobs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Linq;

namespace Company.Function
{
    public static class BlobTriggerCSharp1
    {
        [FunctionName("BlobTriggerCSharp1")]
        public static async Task Run(
            [BlobTrigger("uploads/{name}.{extension}", Connection = "AzureWebJobsStorage_xxxx")] Stream myBlob, 
            string name, 
            string extension, 
            ILogger log)
        {
            log.LogInformation($"Processing blob: {name}.{extension}");

            string connectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage_saizhv01");
            BlobServiceClient blobServiceClient = new BlobServiceClient(connectionString);
            BlobClient blobClient = blobServiceClient.GetBlobContainerClient("uploads").GetBlobClient($"{name}.{extension}");

            string endpoint = Environment.GetEnvironmentVariable("CONTENT_SAFETY_ENDPOINT");
            string key = Environment.GetEnvironmentVariable("CONTENT_SAFETY_KEY");
            ContentSafetyClient contentSafetyClient = new ContentSafetyClient(new Uri(endpoint), new AzureKeyCredential(key));

            ContentSafetyImageData image = new ContentSafetyImageData(BinaryData.FromStream(myBlob));
            AnalyzeImageOptions request = new AnalyzeImageOptions(image);

            try
            {
                Response<AnalyzeImageResult> response = await contentSafetyClient.AnalyzeImageAsync(request);
                var existingMetadata = (await blobClient.GetPropertiesAsync()).Value.Metadata;

                var categoriesAnalysis = response.Value.CategoriesAnalysis;
                bool isRejected = categoriesAnalysis.Any(a => a.Severity > 0); // Strict threshold

                string jsonResponse = System.Text.Json.JsonSerializer.Serialize(response.Value);
                log.LogInformation($"Content Safety API Response: {jsonResponse}");

                var metadataUpdates = new Dictionary<string, string>
                {
                    {"moderation_status", isRejected ? "BLOCKED" : "APPROVED"}
                };

                // Add metadata for each category with detected severity
                foreach (var category in categoriesAnalysis)
                {
                    if (category.Severity > 0)
                    {
                        metadataUpdates.Add($"{category.Category.ToString().ToLower()}_severity", category.Severity.ToString());
                    }
                }

                foreach (var item in metadataUpdates)
                {
                    existingMetadata[item.Key] = item.Value;
                }
                
                await blobClient.SetMetadataAsync(existingMetadata);
                log.LogInformation($"Blob {name}.{extension} metadata updated successfully.");
            }
            catch (RequestFailedException ex)
            {
                log.LogError($"Analyze image failed. Status code: {ex.Status}, Error code: {ex.ErrorCode}, Error message: {ex.Message}");
                throw;
            }
        }
    }
}
