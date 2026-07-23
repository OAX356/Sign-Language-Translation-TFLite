# Sign-Language-Translation-TFLite
Real-Time American Sign Language Translation System into text and speech


# Real-Time Sign Language Translation System

An optimized, on-device Deep Learning solution engineered to translate sign language gestures into text/speech in real time with high inference efficiency.

## 📌 Features & System Capabilities
- **On-Device Inference:** Lightweight architecture designed for low-latency execution without reliance on cloud infrastructure.
- **Holistic Keypoint Tracking:** Integrates gesture keypoint extraction across hand and body poses.
- **Empirical Evaluation:** Evaluated using confusion matrices across 10,000+ data samples to ensure high accuracy and dynamic boundary resolution.

## 🛠️ Tech Stack & Dependencies
- **Core Language:** Dart 3
- **Frameworks & Libraries:** TensorFlow Lite, Google MediaPipe, OpenCV
- **Deployment Target:** Mobile Computing Systems

## 📐 Architecture Overview
1. **Video Stream Input:** Captures real-time camera frames.
2. **Keypoint Extraction Pipeline:** MediaPipe processes landmarks (Hand/Body).
3. **Data Normalization:** Coordinates normalized for invariant boundary prediction.
4. **TFLite Model Execution:** Multi-Layer Perceptron (MLP) outputs translated classification probabilities.
