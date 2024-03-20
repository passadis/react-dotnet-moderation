<p align="center">
  <a href="https://skillicons.dev">
    <img src="https://skillicons.dev/icons?i=azure,react,dotnet,docker,terraform,vscode" />
  </a>
</p>

<h1 align="center">Content Moderation with Azure Content Safety and Custom Metadata</h1>


## Project Overview

This project explores Azure AI Content Safety where users upload Photos that are getting stored to Azure Storage and select categories about them, Azure AI Content Safety performs moderation on the content, and the Moderation status along with the selected categories are stored as Blob custom metadata. Azure Logic Apps integration helps us extract the Custom Metadata of each Blob, store them in a CSV file and Microsoft Fabric brings to life Analysis on the results using a Pipeline to fetch the CSV and visualize it as a Table with a Python notebook

## Introduction

Azure AI Content Safety is an AI service that lets you handle content that is potentially offensive, risky, or otherwise undesirable. It includes the AI-powered content moderation service which scans text, image, and videos and applies content flags automatically.

So we are going to build a React Application where users upload Photos and select some categories about them, Content Safety performs moderation flagging , and Microsoft Fabric brings to life Analysis on the process and the results.

## Prerequisites

For this workshop we need :

   - **Azure Subscription**
   - **VSCode with Node.Js**
   - **Content Safety Resource from Azure AI Services**
   - **Azure Functions**
   - **Azure Container Registry**
   - **Azure Web APP**
   - **Azure Logic Apps**
   - **Azure Storage Accounts**
   - **Microsoft Fabric ( Trial is fine)**

## Getting Started


1. **Set Up Your Development Environment**: Ensure your workstation is equipped with Docker, Azure Functions Core Tools, Python, and Node.js.

2. **Clone the Repository**: Get started by cloning this repository to your local environment.

2. **Follow the Blog for Detailed Instructions**: For step-by-step guidance, visit [Microsoft Fabric and Content Safety:Analytics On Metadata](https://www.cloudblogger.eu/2023/11/20/microsoft-fabric-content-safety-analytics-on-metadata/).

## Contribute

We encourage contributions! If you have ideas on how to improve this application or want to report a bug, please feel free to open an issue or submit a pull request.

## Architecture
![ModArch3](https://github.com/passadis/react-dotnet-moderation/assets/53148138/8379e967-2791-486e-8d8e-caa63d77049d)

