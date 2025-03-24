# DualForce
# Advanced Domain Specific AI Expert Maker

## Overview
Advanced AI Expert Maker is a personalized AI system that creates domain-specific AI experts based on user-provided documents. Built with a robust backend in **Spring Boot**, **MongoDB**, and **Google Cloud Platform (GCP)**, it leverages **Vertex AI Embedding API** and **Gemini API** to generate highly accurate AI models with minimal hallucinations. The frontend is developed in **Flutter (MVVM + Provider)** for seamless expert creation and real-time interactions.

## Features
- **AI Expert Creation**: Users upload documents, which are processed and embedded to generate domain-specific AI experts.
- **Real-time Chat**: Engage with AI experts trained on specific knowledge bases.
- **Secure Authentication**: User login and management using modern authentication techniques.
- **Scalable Backend**: Spring Boot backend hosted on GCP, with a custom batch service for document chunking and embedding.
- **RESTful APIs**: Efficient APIs for expert system management and messaging.

## Tech Stack
### Backend
- **Spring Boot** (Controller-Service-Repository Pattern)
- **MongoDB** (NoSQL Database)
- **Google Cloud Platform (GCP)** (Hosting & AI Services)
- **Vertex AI Embedding API & Gemini API**
- **REST APIs**

### Frontend
- **Flutter** (MVVM Architecture)
- **Provider** (State Management)
- **Dart**
- **Material UI Components**

## Setup Instructions
### Prerequisites
- **Java**
- **Flutter SDK**
- **MongoDB Installed or Cloud Instance**
- **GCP Account with Vertex AI Access**

### Setup
```sh
# Clone the repository
git clone https://github.com/utkarshgupta2009/dualForceProject.git
```
### Backend Setup
```sh
cd dualForceBackend

# Build and run Spring Boot application
./mvnw spring-boot:run
```

### Frontend Setup
```sh
cd dualForceFrontend
flutter pub get
flutter run
```

## API Endpoints
### Authentication
- `POST /auth/signup` – User registration
- `POST /auth/login` – User login

### Expert System
- `POST /expertSystem/create` – Create a new AI expert
- `POST /expertSystem/sendMessage` – Send a message to an AI expert

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to improve.

## License
MIT License. See `LICENSE` for details.

## Contact
For any inquiries, reach out at [developer.utkarshgupta2009@gmail.com](mailto:developer.utkarshgupta2009@gmail.com).

