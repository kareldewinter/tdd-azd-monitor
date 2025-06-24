[comment]: <> (please keep all comment items at the top of the markdown file)
[comment]: <> (please do not change the ***, as well as <div> placeholders for Note and Tip layout)
[comment]: <> (please keep the ### 1. and 2. titles as is for consistency across all demoguides)
[comment]: <> (section 1 provides a bullet list of resources + clarifying screenshots of the key resources details)
[comment]: <> (section 2 provides summarized step-by-step instructions on what to demo)


[comment]: <> (this is the section for the Note: item; please do not make any changes here)
***
### Azure Monitor REST API

<div style="background: lightgreen; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** Below demo steps should be used **as a guideline** for doing your own demos. Please consider contributing to add additional demo steps.
</div>

[comment]: <> (this is the section for the Tip: item; consider adding a Tip, or remove the section between <div> and </div> if there is no tip)

***
### 1. What Resources are getting deployed
<add a one-paragraph lengthy description of what the scenario is about, and what is getting deployed>

Provide a bullet list of the Resource Group and all deployed resources with name and brief functionality within the scenario. 

* Azure Resource Group
* Application Insights
* Data collection endpoint
* Data collection rule
* Log Analytics workspace

<add a screenshot of the deployed Resource Group with resources>

<img src="https://raw.githubusercontent.com/kdewinter/tdd-azd-monitor/refs/heads/main/demoguide/Monitor/screenshot6.png" alt="Overview deployed resources" style="width:70%;">
<br></br>



### 2. What can I demo from this scenario after deployment

Azure Monitor platform provides a REST API that allows directly sending metrics and logs through a standard REST interface, such as the following:
**Custom metrics API**: used for sending custom metrics to Azure Monitor Metrics datastore for Azure resource.
**Logs Ingestion API**: used for storing logs in a Log Analytics workspace.

#### Custom metrics
We can use these REST API to submit a custom metric to Azure Monitor.
First we need to obtain the required permissions to submit the data through the custom API. Once the token that guarantees access is obtained, a definition of our custom metric needs to be established to help Azure Monitor properly handle that data. After that, we submit the metric to the API endpoint and visualize the data.

To send custom metrics to Azure Monitor Metrics, it is necessary to use a managed identity or a service principal depending on the scenario. Azure services that support authentication through Microsoft Entra can request a managed identity when connecting to those resources without the developer or system administrator managing secrets or passwords explicitly. In the other case, Azure services that don’t support this type of authentication, or custom applications that require access to those resources could use a service principal to authenticate themselves and get access.

The identity type must be assigned the **Monitoring Metrics Publisher role** at the required scope. This way, the identity will request an access token from Microsoft Entra ID for the endpoint (https://monitoring.azure.com/) and will be able to submit the custom metric. This endpoint is also called the audience of the token.

Use an existing Azure VM, or create an new Azure VM.
We want to send the **TDDCustomMetric custom metric** to Azure Monitor Metrics. Azure VM supports the usage of managed identities, the identity can be enabled when creating the VM or after the creation process.

<img src="https://raw.githubusercontent.com/kdewinter/tdd-azd-monitor/refs/heads/main/demoguide/Monitor/screenshot1.png" alt="System assigned managed identity" style="width:70%;">
<br></br>

After the VM is created and its system-managed identity associated, we will assign it the Monitoring Metrics Publisher role.

<img src="https://raw.githubusercontent.com/kdewinter/tdd-azd-monitor/refs/heads/main/demoguide/Monitor/screenshot2.png" alt="Monitoring Metrics Publisher role assignment" style="width:70%;">
<br></br>


Using the managed identity, we can connect to the **Azure Instance Metadata Service (IMDS)** (https://learn.microsoft.com/en-us/azure/virtual-machines/instancemetadata-service?tabs=linux) endpoint to obtain a bearer token for the endpoint mentioned earlier. Subsequently, we can use this token to send data to Azure Monitor Metrics, using the following command on your terminal as an example. In this case, the example is executed on a Linux bash shell through the Azure Cloud Shell service. It is  possible to use your local shell or any other shell-like PowerShell with the proper adjustments to the command:

```bash
response=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmonitoring.azure.com%2F' -H Metadata:true -s)
```

The token is inside the JSON response. We need to extract it to reuse it later by defining a shell variable:

```bash
access_token=$(echo $response | python3 -c 'import sys, json; print(json.load(sys.stdin)["access_token"])')
```


Let’s now create a custom metric named TDDCustomMetric in the TDDMetrics namespace for this VM. To do this, we will create the following JSON file:

```json
time=$(date -u +"%Y-%m-%dT%H:%M:%S")
echo '{
  "time": "'$time'",
  "data": {
      "baseData": {
          "metric": "TDDCustomMetric",
          "namespace": "TDDMetrics",
          "dimNames": [
            "TDDProcess"
          ],
          "series": [
            {
              "dimValues": [
                "TDDApp1.exe"
              ],
              "min": 2,
              "max": 12,
              "sum": 14,
              "count": 2
            },
            {
              "dimValues": [
                "TDDApp2.exe"
              ],
              "min": 4,
              "max": 10,
              "sum": 19,
              "count": 3
            }
          ]
      }
  }
}' > TDDCustomMetric.json
```

we are ready to send the custom metric to the custom metrics API. The endpoint URL would be similar to https://{azure_region}.monitoring.azure.com/{azure_resource_id}/metrics, for example, https://westeurope.monitoring.azure.com/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/{resource_group_name}/providers/Microsoft.Compute/virtualMachines/{vm_name}/metrics.

With all the information provided, we can now make the following HTTP POST request to send TDDCustomMetric to Azure Monitor Metrics:

```bash
curl -X POST 'https://eastus2.monitoring.azure.com/$azure_resource_id/metrics' \
-H 'Content-Type: application/json' \
-H "Authorization: Bearer $access_token" \
-d @TDDCustomMetric.json
```

The simplest way to validate it is to check if the custom metric is visible through the Azure portal.

<img src="https://raw.githubusercontent.com/kdewinter/tdd-azd-monitor/refs/heads/main/demoguide/Monitor/screenshot3.png" alt="Metric Namespace and the custom Metric name" style="width:70%;">
<br></br>

Note that since the created metric is multidimensional, there is an option to split the data by the dimension name, as shown next.

<img src="https://raw.githubusercontent.com/kdewinter/tdd-azd-monitor/refs/heads/main/demoguide/Monitor/screenshot4.png" alt="Dimension metric values" style="width:70%;">
<br></br>


We have covered how custom metrics can be integrated into Azure Monitor to have the same experience as native platform and system metrics. The next step is to check how the same process can be achieved for custom logs.

Azure Monitor provides a REST API called Logs Ingestion API for sending logs to the Log Analytics workspace. This can be done using a REST API call or client libraries (.NET, Go, Java, JavaScript, and Python), but the ingestion is supported for a limited set of Azure tables and any custom table created in the Log Analytics workspace.

Submitting custom logs requires a more complex process. It starts with the obtention of the required authentication tokens to be able to submit the information. After that, we need to enable a data collection endpoint (DCE) inside Azure Monitor that would be configured to receive our data. Our logs could go into a specific processing stage before the information is stored inside Log Analytics; these transformations are defined through a DCR. After the information is ready, we can decide whether to store that information inside an existing Azure Monitor Log Analytics table or use a custom one. 

<img src="https://raw.githubusercontent.com/kdewinter/tdd-azd-monitor/refs/heads/main/demoguide/Monitor/screenshot5.png" alt="dcr-flow-diagram" style="width:70%;">
<br></br>

If the source is an Azure VM wanting to send logs via the Logs Ingestion API, you can simply use an Azure-managed identity like in the previous section.

A Data Collection Endpoint is a logical interface created by the Logs Ingestion API to allow our applications to send information for ingestion and processing. The DCE is created in the AZD provisioning step.

We want our custom logs to be stored in a custom table inside the Log Analytics workspace instead of using the default one. We will use a created Log Analytics workspace with the Custom table.

The Custom table is defined by this schema:
```json
  {
    name: 'TimeGenerated'
    type: 'datetime'
    description: 'The time at which the event occurred.'
  }
  {
    name: 'HostName'
    type: 'string'
    description: 'The name of the host generated the event.'
  }
  {
    name: 'EventMessage'
    type: 'dynamic'
    description: 'The data associated with the event.'
  }
```


The Data Collection Rule (DCR) defines how data is ingested, transformed, and sent to a Log Analytics workspace.
The REST API call we will make for sending our logs to the platform will connect first with the previously defined DCE and process the data received based on the DCR associated with it in the ingestion pipeline.
The structure of the ingestion pipeline executed by this type of DCR is as follows:
**Input data structure**: This refers to the schema of the source data intended to be sent to the workspace
**KQL transformations on data**: This allows modification of the structure of the ingested data to adapt it to the schema of the destination table
**Loading data into a destination**: This involves sending and storing the transformed data in the destination table of the workspace

The creation of the DCR has been successful with the AZD deployment. Pay specific attention to the **ImmutableID value**, which you will find in the Output of the deployment and you will need in the final step for sending logs to the Logs Ingestion API.


In this step, we assign the **Monitoring Metrics Publisher** role to Managed Identity of the VM. The required scope, in this case, would be the DCR, so that the application can send data to the DCE, and it can be processed by the DCR.



```bash
response=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmonitor.azure.com%2F' \
  -H 'Metadata:true' \
  -s)
access_token=$(echo $response | python3 -c 'import sys, json; print(json.load(sys.stdin)["access_token"])')
```


The final step is to submit your custom logs and verify their successful receipt.

Sending data to the Logs Ingestion API
To send logs to the Logs Ingestion API, there are two options: Client libraries and REST API call.

The REST API POST request to the https://<Data Collection EndpointURI>/dataCollectionRules/<DCR Immutable ID>/streams/{StreamName}?api-version=2023-01-01 endpoint with a content body in JSON array format containing the data to be sent, whose data structure matches that defined in the DCR stream.

```bash
curl -X POST 'https://dce-tdd-logs-ingestion-h211.eastus2-1.ingest.monitor.azure.com/dataCollectionRules/dcr-13e19efccf22444d82r7849a4118cb1e/streams/Custom-TDDTable?api-version=2023-01-01' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiL....X8kMnPqR2sT9vW3yZ4aB5cD6e' \
  -d '[
    {
      "timestamp": "2024-08-15T14:22:18Z",
      "hostname": "WEB-SERVER-01",
      "eventMessage": {
        "src_ip": "192.168.1.45",
        "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
        "username": "webadmin",
        "result": "Successful Authentication",
        "session_id": "sess_abc123def456ghi789",
        "description": "Administrator successfully authenticated to web management portal via HTTPS."
      }
    },
    {
      "timestamp": "2024-08-15T14:18:32Z",
      "hostname": "DB-SERVER-02",
      "eventMessage": {
        "src_ip": "172.16.0.100",
        "user_agent": "Database Client v2.5.1",
        "username": "dbuser",
        "result": "Connection Established",
        "database": "ProductionDB",
        "description": "Database connection established successfully from application server."
      }
    },
    {
      "timestamp": "2024-08-15T14:15:07Z",
      "hostname": "API-GATEWAY",
      "eventMessage": {
        "src_ip": "203.0.113.42",
        "user_agent": "PostmanRuntime/7.32.3",
        "username": "api_client_001",
        "result": "Rate Limit Exceeded",
        "api_endpoint": "/api/v1/users",
        "description": "API request blocked due to rate limiting - client exceeded 1000 requests per hour."
      }
    }
  ]'
```


It is possible to verify that the logs have been properly ingested through the Log Analytics workspace interface inside the Azure portal. The first time data is ingested into a table, it can take up to 15 minutes for it to appear.



[comment]: <> (this is the closing section of the demo steps. Please do not change anything here to keep the layout consistant with the other demoguides.)
<br></br>
***
<div style="background: lightgray; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** This is the end of the current demo guide instructions.
</div>




