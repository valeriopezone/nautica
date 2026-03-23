# Nautica Dashboard ⚓

An interactive marine dashboard that connects to **SignalK** and allows users to visualize data from multiple onboard sensors, providing a fully digital and customizable instrument panel for boats and ships.

Built with **Flutter (Dart)** and designed for **Android devices**, tablets, and onboard displays.

---

## ✨ Features

- 📡 SignalK server connection  
- 📊 Real-time sensor data visualization  
- 🧭 Digital marine instruments  
- 🧩 Modular dashboard layout  
- 📱 Optimized for tablets and touch screens  
- 🚤 Designed for boats, yachts, and ships  
- ⚙️ Configurable widgets  
- 🔄 Live data updates  

---

## 📡 Supported Data (via SignalK)

The dashboard can display any data exposed by SignalK, including:

- GPS position  
- Speed (SOG / STW)  
- Wind speed and direction  
- Depth  
- Heading / Compass  
- Water temperature  
- Air temperature  
- Battery voltage  
- Chartplotter 
- Custom SignalK data paths  

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed  
- Android Studio  
- Android device or emulator  
- SignalK server running  
- Network access to SignalK server  

---

## 🔧 Installation

Clone the repository:

```bash
git clone https://github.com/valeriopezone/nautica.git
cd nautica
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

---

## ⚙️ Configuration

Configure the SignalK server address inside the app settings.

Examples:

```
http://192.168.1.100:3000
```


The app will connect and start receiving real-time data.

---

## 📱 Target Devices

- Android tablets (recommended)
- Android phones
- Embedded Android displays
- Marine cockpit touch displays
- Dedicated onboard screens

---

## 🧭 Use Cases

- Sailboat instrument panel  
- Motorboat dashboard  
- Navigation station display  
- Cockpit tablet display  
- Dedicated onboard instrument screen  

---

## 🛠️ Built With

- Flutter  
- Dart  
- SignalK API  
- WebSocket real-time streaming  

---

## 📄 License

MIT License

---

## 🤝 Contributing

Contributions are welcome!  
Feel free to open issues or submit pull requests.

---

## ⚓ Nautica

Modern digital instrumentation for marine navigation.
