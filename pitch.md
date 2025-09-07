# Pitch: Prism - The Future of Intelligent and Secure Banking

**Presenter:** Darshan from Code Strikers
**Time:** 10 Minutes
**Track:** AI for Core Applications

---

### (Minute 0:00-1:00) Introduction: The Problem with Digital Banking Today

Good morning, judges.

We are **Code Strikers**, and my name is Darshan. We are here today to present Prism, our project for the **'AI for Core Applications'** track. Our chosen core application is **banking**—an industry fundamental to our daily lives, yet ripe for an intelligent transformation.

Let's talk about the state of digital banking. It's a convenience we all use, but it's far from perfect. We've all experienced the frustration: clunky interfaces, generic and unhelpful chatbots, and the constant worry about security. Is my data safe? What happens if my password is stolen?

Traditional banks are struggling to keep up. This leads to a disconnected and often insecure user experience.

Today, we're here to introduce a solution that is not just a banking app, but a complete ecosystem where AI is woven into the very fabric of the core application.

---

### (Minute 1:00-2:30) Our Solution: Introducing Prism

We call it **Prism**.

Prism is a revolutionary mobile banking platform and a direct answer to the challenge of the 'AI for Core Applications' track. It's an ecosystem where AI is not an add-on, but **fundamental to the core user experience**.

At its heart, Prism consists of three main components:

1.  **The Prism Mobile App:** A beautifully designed Flutter application that provides a seamless and intuitive user experience for all core banking needs.
2.  **The Prism AI Assistant:** A sophisticated multi-agent AI system, powered by Google's Gemini, that provides specialized and context-aware customer support, directly integrated into the application's core functions.
3.  **Prism Secure:** A multi-layered security suite that uses AI to go beyond passwords, incorporating behavioral biometrics and location intelligence to protect users.

Let's dive into how AI enhances each of these core components.

---

### (Minute 2:30-8:00) A Deeper Dive: Our Core AI-Powered Features

#### 1. Prism Secure: AI-Powered Keystroke Authentication

First, let's address a major security flaw: passwords. They can be stolen, guessed, or phished. Prism introduces **Keystroke Dynamics**—a form of behavioral biometrics.

*   **How it Works:** The system learns your unique typing rhythm—how long you hold down keys and the time between your key presses. When you log in, it doesn't just check *what* you type, but *how* you type. If the pattern doesn't match, access is denied, even with the correct password.
*   **The Tech Stack:** This is powered by a **Python Flask backend**. We capture keystroke timings from the app and send them to the backend, which uses a **Scikit-learn Isolation Forest model** to create a unique profile for each user and detect anomalies.

#### 2. Prism Secure: Intelligent Location-Based Security

Next, we add contextual security with location intelligence.

*   **How it Works:** Within the Prism app, you can designate certain places like your 'Home' or 'Office' as **Trusted Locations**. When you make payments from these zones, the experience is seamless. However, if a high-value transaction is attempted from an unfamiliar location, Prism’s security protocol kicks in, requiring additional verification.
*   **The Tech Stack:** This is managed by our `LocationSecurityService` within the **Flutter application**. It uses the device's GPS and communicates securely with our **Firebase Firestore** database, where trusted zones are stored for each user.

#### 3. The Prism AI Assistant: A Specialized Multi-Agent System

This is the heart of our 'AI for Core Applications' theme. We’ve replaced the generic, unhelpful chatbot with a powerful **Multi-Agent System**.

*   **How it Works:** Instead of one AI trying to know everything, we have a team of specialized agents. When you ask a question, a router agent directs it to the correct specialist. Our available agents include:
    *   **Account Agent:** For balance checks and transaction history.
    *   **Loan Agent:** For eligibility queries and interest rates.
    *   **Card Agent:** For managing your credit/debit cards.
    *   **Support Agent:** For all other general questions.
*   **The Tech Stack:** This system is a **Python backend** built with our own **Agent Development Kit (ADK)** using the **FastAPI** framework. Each agent leverages the powerful reasoning of the **Google Gemini API** to understand the query and provide an accurate, context-aware response.

#### 4. Proactive Security: Real-time Transaction Monitoring

Finally, Prism actively protects you with a proactive notification system.

*   **How it Works:** The system constantly monitors for unusual activity. For example, if a transaction of **more than 2000 Rupees** is initiated from an untrusted location, you receive an **instant security alert** on your device. This ensures you are always aware of your account activity and can act immediately if something is suspicious.
*   **The Tech Stack:** This is handled by our real-time `TransactionMonitoringService` in the Flutter app, which is tightly integrated with **Firebase** to check transaction amounts and location status.

---

### (Minute 8:00-9:00) Why Prism? The Value Proposition

So, why Prism?

**For Customers:** We offer a banking experience that is finally smart, secure, and user-friendly. With Prism, you have a personal banker in your pocket and the peace of mind that your finances are protected by AI-driven security.

**For Banks:** Prism is a game-changer. By deeply integrating AI into customer support, we can significantly reduce operational costs. Our advanced, AI-powered security features can minimize fraud and increase customer trust. In a competitive market, Prism offers a powerful way for banks to innovate on their core application.

---

### (Minute 9:00-10:00) Conclusion: The Future of Core Applications is AI

Judges, the future of banking—and indeed, all core applications—is not just about digitizing existing services. It's about making them more intelligent, more secure, and more human by deeply integrating AI.

Prism is our vision for that future and a testament to the power of **'AI for Core Applications'**. It's a comprehensive ecosystem that seamlessly blends cutting-edge AI, robust security, and a user-centric design.

We believe that Prism has the potential to redefine what a mobile banking experience can be.

Thank you.
