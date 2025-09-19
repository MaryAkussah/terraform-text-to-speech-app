
---

# 🎤 AWS Text-to-Speech (TTS) Application

A **scalable, serverless text-to-speech application** built with AWS services. It provides secure user authentication, real-time speech synthesis, and comprehensive monitoring using AWS best practices.

---

## 🏗️ Architecture Overview

<img width="926" height="530" alt="TTS Architecture" src="architecture img/Screenshot 2025-09-18 124122.png" />  


<img width="926" height="530" alt="TTS Architecture" src="architecture img/Screenshot 2025-09-18 124320.png" />  

**High-Level Flow:**

1. User accesses frontend hosted on **Amazon S3**
2. **Amazon Cognito** handles authentication and JWT token issuance
3. **API Gateway** routes requests securely with Cognito authorization
4. **AWS Lambda** integrates with **Amazon Polly** for text-to-speech conversion
5. Audio is stored in **Amazon S3 (Audio Bucket)**
6. A **Presigned URL** is returned to the frontend for playback/download
7. **CloudWatch, X-Ray, and SNS** provide monitoring, tracing, and alerts

---

## 🚀 Features

* **🔐 Secure Authentication** with AWS Cognito (sign-up, sign-in, email verification)
* **⏰ Session Management**: Auto-logout after 10 minutes of inactivity
* **🎭 Voice Selection**: 15+ Amazon Polly voices across US, UK, AU, and IN
* **📱 Responsive Design**: Mobile-first UI with modern navigation
* **⬇️ Audio Download**: Direct MP3 downloads via Presigned URLs
* **♻️ Auto-Cleanup**: S3 lifecycle deletes audio files after 7 days
* **📊 Monitoring & Alerts**: CloudWatch dashboards, alarms, and SNS notifications
* **🔍 Distributed Tracing**: End-to-end visibility with AWS X-Ray
* **🔄 Auto-Regeneration**: Recreate audio when voice/country is changed

---

## 🛠️ AWS Services

### Core Services

| Service         | Resource    | Purpose                            |
| --------------- | ----------- | ---------------------------------- |
| **S3**          | 2 Buckets   | Frontend hosting & audio storage   |
| **Lambda**      | 1 Function  | Text-to-speech processing          |
| **API Gateway** | HTTP API    | RESTful API endpoint               |
| **Cognito**     | User Pool   | Authentication & JWT authorization |
| **Polly**       | TTS Service | Speech synthesis                   |
| **DynamoDB**    | 1 Table     | Metadata storage                   |

### Monitoring & Logging

| Service        | Resource   | Purpose                             |
| -------------- | ---------- | ----------------------------------- |
| **CloudWatch** | Log Groups | Capture Lambda & API Gateway logs   |
| **CloudWatch** | 4 Alarms   | Monitor errors, latency, duration   |
| **CloudWatch** | Dashboard  | Centralized metrics visualization   |
| **SNS**        | Topic      | Email alerts for system issues      |
| **X-Ray**      | Tracing    | Performance and dependency analysis |

---

## 📁 Project Structure

```
terraform-tts-deployment/
├── main.tf              # Core infrastructure
├── monitoring.tf        # Logging & monitoring setup
├── dashboard.tf         # CloudWatch dashboard
├── variables.tf         # Configuration variables
├── outputs.tf           # Resource outputs
├── index.html           # Frontend application
├── lambda/
│   ├── tts_lambda.py    # Lambda function code
│   └── tts_lambda.zip   # Deployment package
├── deploy-monitoring.bat # Deployment script
└── README.md            # Documentation
```

---

## ⚡ Deployment Guide

### Prerequisites

* AWS CLI configured
* Terraform v1.5+
* Python 3.11+

### Steps

1. **Clone & Configure**

   ```bash
   git clone <your-repo-url>
   cd terraform-tts-deployment
   ```

2. **Update Variables**

   ```hcl
   variable "alert_email" {
     default = "maryakussah123@gmail.com"  
   }
   ```

3. **Deploy Core Infrastructure**

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Deploy Monitoring (Optional)**

   ```bash
   # Windows
   deploy-monitoring.bat

   # Linux/Mac
   terraform apply -var="alert_email=maryakussah123@gmail.com"
   ```

5. **Upload Frontend**

   ```bash
   aws s3 cp index.html s3://my-tts-website-terraform/
   ```

---

## 📊 Monitoring & Alerts

* **CloudWatch Alarms**:

  * Lambda error rate >5%
  * Lambda duration >10s
  * API 4XX >10/5min
  * API 5XX (any occurrence)

* **Log Groups**:

  * `/aws/lambda/PollyTTSLambda`
  * `/aws/apigateway/PollyTTSAPI`

* **Dashboards**:

  * Lambda: invocations, errors, duration
  * API Gateway: requests, latency, errors

---

## 🔧 Configuration

### Voice Options

```javascript
const voices = {
  US: ['Joanna', 'Matthew', 'Ivy', 'Justin', 'Salli', 'Kimberly', 'Joey'],
  UK: ['Amy', 'Brian', 'Emma'],
  AU: ['Russell', 'Nicole', 'Olivia'],
  IN: ['Raveena', 'Aditi']
};
```

### Session Management

* Auto-logout after 10 minutes
* Monitors mouse, keyboard, touch, scroll events
* Silent logout → redirect to login

### Limits

* Max input: **3000 characters**
* Warning at 2500+ characters
* MP3 output, 7-day retention, 1-hour Presigned URLs

---

## 🎯 Roadmap

### Security Enhancements

* [ ] API rate limiting
* [ ] AWS WAF integration
* [ ] VPC endpoints for private traffic
* [ ] IAM key rotation policy

### Performance Improvements

* [ ] Add CloudFront CDN
* [ ] Enable Lambda provisioned concurrency
* [ ] Use S3 Transfer Acceleration
* [ ] Add Redis caching layer

### Feature Additions

* [x] Session Timeout ✅
* [x] Multi-Country Voices ✅
* [x] Auto-Regeneration ✅
* [ ] SSML support
* [ ] Voice cloning
* [ ] Batch processing
* [ ] Audio effects (speed, pitch, volume)
* [ ] Conversion history
* [ ] Audio sharing links

---

## 💰 Cost Optimization

### Current Estimates

* **Lambda**: \~\$0.20 / 1M requests
* **API Gateway**: \~\$1.00 / 1M requests
* **S3**: \~\$0.023 / GB / month
* **Polly**: \~\$4.00 / 1M characters
* **CloudWatch**: \~\$0.50 / GB logs

### Recommendations

* Enable **S3 Intelligent Tiering**
* Optimize **Lambda memory allocation**
* Use **request caching** in API Gateway
* Set up **billing alerts**

---

## 🐛 Troubleshooting

**Authentication Errors**

```bash
aws cognito-idp describe-user-pool --user-pool-id <pool-id>
```

**Lambda Timeouts**

```bash
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda"
```

**S3 Upload Issues**

```bash
aws s3api get-bucket-policy --bucket my-tts-website-terraform
```

---

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

---

## 📄 License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

* AWS Documentation & Sample Code
* Terraform AWS Provider
* Bootstrap CSS Framework
* Amazon Polly Voice Samples
* Amazon Q

---

✨ If you find this project useful, please **star ⭐ the repo** to support development!

---

