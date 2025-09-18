# 🎤 AWS Text-to-Speech Application

A serverless text-to-speech application built with AWS services, featuring user authentication, real-time speech synthesis, and comprehensive monitoring.

## 🏗️ Architecture Overview


<img width="926" height="530" alt="Screenshot 2025-09-18 124122" src="architecture img/Screenshot 2025-09-18 124320.png" />

<img width="926" height="530" alt="Screenshot 2025-09-18 124122" src="architecture img/Screenshot 2025-09-18 124122.png" />

## 🚀 Features

- **🔐 User Authentication**: Secure sign-up/sign-in with AWS Cognito
- **⏰ Session Timeout**: Auto-logout after 10 minutes of inactivity
- **🎭 Multiple Voices**: 15+ AWS Polly voices across 4 countries
- **🌍 Multi-Country Support**: US, UK, Australia, India voices
- **📱 Responsive Design**: Mobile-first UI with hamburger menu
- **⬇️ Audio Download**: Direct MP3 download functionality
- **🔄 Auto-Cleanup**: 7-day lifecycle policy for audio files
- **📊 Monitoring**: CloudWatch logs, alarms, and dashboard
- **🔍 Tracing**: AWS X-Ray integration for debugging
- **🔄 Auto-Regeneration**: Audio updates when voice/country changes

## 🛠️ AWS Resources Used

### Core Services
| Service | Resource | Purpose |
|---------|----------|---------|
| **S3** | 2 Buckets | Frontend hosting + Audio storage |
| **Lambda** | 1 Function | Text-to-speech processing |
| **API Gateway** | HTTP API | RESTful API endpoint |
| **Cognito** | User Pool | Authentication & authorization |
| **Polly** | TTS Service | Speech synthesis |
| **DynamoDB** | 1 Table | Metadata storage |

### Monitoring & Logging
| Service | Resource | Purpose |
|---------|----------|---------|
| **CloudWatch** | Log Groups | Lambda & API Gateway logs |
| **CloudWatch** | 4 Alarms | Error rate & duration monitoring |
| **CloudWatch** | Dashboard | Centralized metrics view |
| **SNS** | Topic | Alert notifications |
| **X-Ray** | Tracing | Request flow analysis |

## 📁 Project Structure

```
terraform-tts-deployment/
├── 📄 main.tf              # Core infrastructure
├── 📄 monitoring.tf        # Logging & monitoring setup
├── 📄 dashboard.tf         # CloudWatch dashboard
├── 📄 variables.tf         # Configuration variables
├── 📄 outputs.tf           # Resource outputs
├── 📄 index.html           # Frontend application
├── 📁 lambda/
│   ├── 🐍 tts_lambda.py    # Lambda function code
│   └── 📦 tts_lambda.zip   # Deployment package
├── 📄 deploy-monitoring.bat # Deployment script
└── 📄 README.md            # This file
```

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured
- Terraform >= 1.5.0
- Python 3.11+

### Deployment Steps

1. **Clone & Configure**
   ```bash
   git clone <your-repo-url>
   cd terraform-tts-deployment
   ```

2. **Update Variables**
   ```bash
   # Edit variables.tf
   variable "alert_email" {
     default = "maryakussah123@gmail.com"  
   }
   ```

3. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Deploy Monitoring** (Optional)
   ```bash
   # Windows
   deploy-monitoring.bat
   
   # Linux/Mac
   terraform apply -var="alert_email= maryakussah123@gmail.com"
   ```

5. **Upload Frontend**
   ```bash
   aws s3 cp index.html s3://my-tts-website-terraform/
   ```

## 📊 Monitoring & Alerts

### CloudWatch Alarms
- **Lambda Error Rate**: Triggers when >5% error rate
- **Lambda Duration**: Alerts on >10s execution time
- **API 4XX Errors**: Monitors client errors >10/5min
- **API 5XX Errors**: Alerts on any server errors

### Log Groups
- `/aws/lambda/PollyTTSLambda`: Function execution logs
- `/aws/apigateway/PollyTTSAPI`: API request/response logs

### Dashboard Metrics
- Lambda invocations, errors, duration
- API Gateway request count, latency, errors
- Recent log entries

## 🔧 Configuration Options

### Voice Selection
```javascript
// Available voices by country
const voices = {
  US: ['Joanna', 'Matthew', 'Ivy', 'Justin', 'Salli', 'Kimberly', 'Joey'],
  UK: ['Amy', 'Brian', 'Emma'],
  AU: ['Russell', 'Nicole', 'Olivia'],
  IN: ['Raveena', 'Aditi']
};
```

### Session Management
- **Timeout**: 10 minutes of inactivity
- **Activity Tracking**: Mouse, keyboard, touch, scroll events
- **Silent Logout**: No warning, automatic redirect to login

### Text Limits
- **Maximum**: 3000 characters
- **Validation**: Client & server-side
- **Warning**: Visual indicators at 2500+ chars

### Audio Storage
- **Format**: MP3
- **Retention**: 7 days (auto-delete)
- **Access**: Presigned URLs (1-hour expiry)

## 🎯 Improvements & Next Steps

### 🔒 Security Enhancements
- [ ] Implement rate limiting
- [ ] Add WAF protection
- [ ] Enable VPC endpoints
- [ ] Rotate access keys regularly

### 🚀 Performance Optimizations
- [ ] Add CloudFront CDN
- [ ] Implement Lambda provisioned concurrency
- [ ] Use S3 Transfer Acceleration
- [ ] Add Redis caching layer

### 📱 Feature Additions
- [x] **Session Timeout**: 10-minute auto-logout ✅
- [x] **Multi-Country Voices**: US, UK, AU, IN support ✅
- [x] **Auto-Regeneration**: Voice change triggers new audio ✅
- [ ] **SSML Support**: Advanced speech markup
- [ ] **Voice Cloning**: Custom voice training
- [ ] **Batch Processing**: Multiple text files
- [ ] **Audio Effects**: Speed, pitch, volume controls
- [ ] **History**: User's previous conversions
- [ ] **Sharing**: Public audio links

### 🔍 Monitoring Improvements
- [ ] Custom metrics dashboard
- [ ] Cost monitoring alerts
- [ ] Performance insights
- [ ] User analytics tracking

### 🏗️ Architecture Enhancements
- [ ] **Multi-region**: Global deployment
- [ ] **Microservices**: Split into smaller functions
- [ ] **Event-driven**: SQS/EventBridge integration
- [ ] **CI/CD Pipeline**: Automated deployments

## 💰 Cost Optimization

### Current Costs (Estimated)
- **Lambda**: ~$0.20/million requests
- **API Gateway**: ~$1.00/million requests
- **S3**: ~$0.023/GB/month
- **Polly**: ~$4.00/million characters
- **CloudWatch**: ~$0.50/GB ingested

### Cost Reduction Tips
- Use S3 Intelligent Tiering
- Implement request caching
- Optimize Lambda memory allocation
- Set up billing alerts

## 🐛 Troubleshooting

### Common Issues

**Authentication Errors**
```bash
# Check Cognito configuration
aws cognito-idp describe-user-pool --user-pool-id <pool-id>
```

**Lambda Timeouts**
```bash
# Check CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda"
```

**S3 Upload Failures**
```bash
# Verify bucket permissions
aws s3api get-bucket-policy --bucket my-tts-website-terraform
```

## 📞 Support & Contributing

### Getting Help
- Check CloudWatch logs first
- Review AWS service quotas
- Validate IAM permissions
- Test with minimal input

### Contributing
1. Fork the repository
2. Create feature branch
3. Add tests for new features
4. Submit pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- AWS Documentation & Examples
- Terraform AWS Provider
- Bootstrap CSS Framework
- AWS Polly Voice Samples
-Amazon Q
---

**⭐ Star this repo if it helped you build your own TTS application!**