# API Gateway + Lambda + MySQL CRUD Project

## Architecture
Browser → API Gateway → Lambda → MySQL (RDS)

## Methods Implemented
- GET
- POST
- PUT
- DELETE

## Setup Steps
1. Create MySQL RDS
2. Run db.sql
3. Create Lambda and upload deployment zip
4. Add environment variables:
   - DB_HOST
   - DB_NAME
   - DB_USER
   - DB_PASSWORD
5. Create API Gateway HTTP API
6. Enable CORS
7. Deploy
8. Replace API URL in index.html
