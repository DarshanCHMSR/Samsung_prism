# PPT Blueprint: Prism - A Technical Deep Dive

This document outlines the content for a detailed technical presentation on the Prism project. Each section represents a slide or a group of related slides.

---

### Slide 1: Title Slide

*   **Title:** Prism: An AI-Powered Banking Ecosystem
*   **Subtitle:** A Technical Deep Dive into an Intelligent, Secure Financial Platform
*   **Team:** Code Strikers
*   **Presenter(s):** Darshan
*   **Track:** AI for Core Applications
*   **Visuals:** A clean, modern graphic representing AI, security, and finance. The project logo if available.

---

### Slide 2: Introduction & Vision

*   **Title:** Our Vision: Redefining Digital Banking
*   **Content:**
    *   **Who We Are:** We are Code Strikers, a team passionate about applying AI to solve real-world problems.
    *   **The Problem:** Today's banking apps are functional but lack intelligence and robust security. They suffer from generic chatbots, password-based vulnerabilities, and a lack of contextual awareness.
    *   **Our Vision:** To create a banking platform where AI is not an afterthought, but a core component that makes the experience more intelligent, intuitive, and fundamentally secure.
*   **Visuals:** A split screen showing a frustrating chatbot interaction on one side and a sleek, intelligent interface on the other.

---

### Slide 3: System Architecture Overview

*   **Title:** Prism: A Decoupled, Multi-Layered Ecosystem
*   **Content:**
    *   Introduction to the three primary, independent services that form the Prism ecosystem.
    *   **1. Flutter Frontend:** The user's gateway to the Prism ecosystem.
    *   **2. AI Backend:** The brains of the operation, handling all intelligent processing.
    *   **3. Security Backend:** A dedicated service for behavioral biometric authentication.
    *   **4. Cloud Infrastructure:** Firebase as the central nervous system for data.
*   **Visuals:** A high-level architectural diagram showing the main components and their interactions:
    *   `[Flutter App]` <=> `[Firebase (Database & Auth)]`
    *   `[Flutter App]` <=> `[FastAPI Multi-Agent Backend]` (via REST API)
    *   `[Flutter App]` <=> `[Flask Keystroke Backend]` (via REST API)
    *   `[FastAPI Backend]` <=> `[Google Gemini API]`
    *   `[FastAPI Backend]` <=> `[Firebase Admin SDK]`

---

### Slide 4: Deep Dive: The Multi-Agent AI Backend

*   **Title:** The Brains: A Specialized Multi-Agent System
*   **Content:**
    *   **Core Idea:** Moving beyond monolithic chatbots to a team of AI specialists for higher accuracy and capability.
    *   **Tech Stack:**
        *   **Framework:** Python with **FastAPI** for high-performance, asynchronous API endpoints.
        *   **AI Engine:** **Google Gemini API** for advanced reasoning, natural language understanding, and response generation.
        *   **Our Implementation:** The `MultiAgentSystem` class acts as a smart router, directing user queries to the appropriate agent based on confidence scoring.
    *   **The Agents:**
        *   `AccountAgent`: Handles balance, transactions, and account details.
        *   `LoanAgent`: Manages loan eligibility, rates, and product information.
        *   `CardAgent`: For card status, limits, and management.
        *   `SupportAgent`: A generalist for all other queries.
*   **Visuals:**
    *   A diagram illustrating the query flow: `User Query -> MultiAgentSystem -> Confidence Scoring -> Route to Best Agent (e.g., LoanAgent) -> Process with Gemini -> Return Response`.
    *   A code snippet from `multi_agent_system.py` showing the agent initialization or the routing logic.

---

### Slide 5: Deep Dive: The Keystroke Security Backend

*   **Title:** The Guardian: AI-Powered Keystroke Authentication
*   **Content:**
    *   **Concept:** Passwords can be stolen, but your typing rhythm is unique. We authenticate the user, not just the password.
    *   **Tech Stack:**
        *   **Framework:** Python with **Flask**, a lightweight choice for a dedicated microservice.
        *   **ML Library:** **Scikit-learn**.
        *   **Algorithm:** `IsolationForest`—an unsupervised learning algorithm, perfect for anomaly detection. It learns a user's normal typing pattern and identifies outliers (imposters).
    *   **How It Works:**
        1.  **Feature Extraction:** The backend calculates `Hold Time` (key press duration) and `Flight Time` (time between key presses) from raw timing data sent by the app.
        2.  **Training:** During enrollment, these features are used to train a unique `IsolationForest` model for the user, which is then saved.
        3.  **Prediction:** At login, the new typing pattern is compared against the model. The model returns `1` for an inlier (genuine) and `-1` for an outlier (imposter).
*   **Visuals:**
    *   An animation showing the extraction of timing data from a word like "P-R-I-S-M".
    *   A code snippet from `keystroke_auth_backend/app.py` showing the `model.predict()` call in the `/predict` endpoint.

---

### Slide 6: Deep Dive: The Flutter Application & Services

*   **Title:** The Experience: A Smart & Secure Frontend
*   **Content:**
    *   **Framework:** **Flutter & Dart** for a single, high-performance codebase across iOS and Android.
    *   **Architecture:** MVVM (Model-View-ViewModel) with **Provider** for clean and reactive state management.
    *   **Key Services:**
        *   `LocationSecurityService`: Manages trusted locations, checks transaction context, and triggers alerts. It contains the logic to check for transactions > 2000 Rs in untrusted zones.
        *   `AgentApiService`: Handles all HTTP communication with the FastAPI backend.
        *   `KeystrokeAuthService`: Communicates with the Flask backend for keystroke authentication.
*   **Visuals:**
    *   Screenshots of the app's UI (e.g., home screen, trusted locations settings page).
    *   A code snippet from `location_security_service.dart` showing the `checkTransactionSecurity` function.

---

### Slide 7: Feature in Action: The End-to-End Flow

*   **Title:** Feature in Action: A Complete User Journey
*   **Content:** A step-by-step walkthrough of a complete user session.
    *   **1. Login:** User types credentials. Keystroke data is sent to the Flask backend for verification.
    *   **2. High-Value Transaction:** User initiates a 5000 Rs payment from an untrusted location.
    *   **3. Alert:** The Flutter app's `LocationSecurityService` detects the anomaly and triggers a real-time security alert via Firebase.
    *   **4. AI Query:** User asks the AI Assistant, "Why did I get a security alert?"
    *   **5. AI Response:** The query is routed to the `SupportAgent`, which explains the transaction was from an untrusted location and provides guidance.
*   **Visuals:** A sequence diagram illustrating this entire end-to-end flow, showing how all components of the system interact.

---

### Slide 8: Innovation & Uniqueness

*   **Title:** What Makes Prism a Market Differentiator?
*   **Content:**
    *   **Intelligent Customer Support:** We replace generic chatbots with a **specialized multi-agent system**, leading to faster, more accurate resolutions.
    *   **Proactive, Invisible Security:** **Keystroke Dynamics** provides a layer of security that is both stronger than passwords and invisible to the user.
    *   **Context-Aware Transactions:** **Location Intelligence** reduces friction for legitimate transactions while adding security where it's needed most.
    *   **Robust Microservices Architecture:** Our decoupled backend services are scalable, maintainable, and independently deployable.

---

### Slide 9: Future Roadmap

*   **Title:** The Future of Prism: What's Next?
*   **Content:**
    *   **Expanding the AI Team:** Introduce new agents like a `FraudDetectionAgent` that proactively freezes suspicious transactions or an `InvestmentAgent` for financial advice.
    *   **Richer Behavioral Biometrics:** Incorporate more patterns, such as swipe gestures and accelerometer data, into the security model.
    *   **Predictive Banking:** Use transaction history to provide users with predictive insights and financial planning advice.
    *   **Cloud Deployment:** Containerize backend services with **Docker** and deploy to a scalable cloud platform like Google Kubernetes Engine (GKE) or AWS ECS.

---

### Slide 10: Conclusion & Q&A

*   **Title:** Prism: Building the Future of Intelligent Banking
*   **Content:**
    *   **Summary:** Prism successfully demonstrates how deeply integrating AI into a core application like banking can create a vastly superior user experience.
    *   **Final Statement:** We’ve built a platform that is not only more intelligent but also fundamentally more secure, setting a new standard for digital finance.
*   **Call to Action:** Thank you. We are now open for questions.
*   **Visuals:** A final slide with contact information, a link to the project's GitHub repository, and a thank you message.
