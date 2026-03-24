
# **Exile: A Journey to Hell**

## 📖 Overview

**Exile: A Journey to Hell** is a 2D dark fantasy action-platformer developed as a **final year Computer Science Engineering project**.

It focuses on building a **modular, scalable, and maintainable game architecture**, using a platformer as the testing environment.

---

## 🎮 Game Concept

The player controls a **righteous fisherman** whose son has been condemned to Hell.
To rescue him, the player journeys through hostile environments, battling enemies and overcoming platforming challenges.

### Core Gameplay

* ⚔️ Combat with enemies and bosses
* 🧭 Exploration across levels
* 🪜 Platforming and environmental navigation

---

## 🧠 Project Goals

The main objective of this project was to apply and demonstrate key **software architecture principles**:

* **Separation of Concerns**
  Independent systems for player, enemies, UI, and game flow

* **Modular Design**
  Systems designed as reusable, loosely coupled components

* **Centralized Game Flow Control**
  A single controller manages level transitions, respawning, and progression

* **Event-Driven Communication**
  Systems communicate via signals/events instead of direct references

* **Scalability & Maintainability**
  Architecture supports adding new levels and features without major refactoring

---

## 🏗️ Architecture Overview

### Core Components

* **GameRoot (Central Controller)**
  Handles:

  * Level loading/unloading
  * Player respawning
  * Game progression and completion

* **Player System**

  * Persistent across levels
  * Handles movement, combat, and interaction

* **Level Scenes**

  * Contain terrain, enemies, and bosses
  * Independent and reusable

* **Enemy & Boss Systems**

  * Shared architecture across all enemies
  * Configurable behavior via parameters
  * Bosses extend the same system without controlling progression

* **UI Layer**

  * Updates based on events
  * Does not directly control gameplay logic

---

## 🤖 Enemy AI Design

Enemy behavior is implemented using a **condition-driven approach**:

* Actions depend on real-time conditions such as:

  * Player proximity
  * Attack range
  * Health status

* Behavior includes:

  * Patrol
  * Chase
  * Attack
  * Death

This approach allows flexible and predictable behavior without the complexity of a formal state machine, while still following a state-like model.

---

## 🔗 Communication Model

The project uses **event-driven communication**:

* Systems emit signals/events when state changes occur
* Other systems listen and react accordingly

### Example:

* Enemy emits a signal when defeated
* GameRoot handles progression
* UI updates based on the same event

This reduces tight coupling and improves modularity.

---

## 🧪 Testing Approach

Testing was primarily:

* **Manual**
* **Scenario-based**

Due to the real-time nature of gameplay (input, timing, animations), automated testing was not prioritized within the project scope.

---

## ⚠️ Scope & Limitations

* The project includes **3 playable levels**
* Core systems are **fully implemented and functional**
* Some features (e.g., pause/resume, extended content) are not included

These limitations are **intentional**, as the focus of the project is on **architectural design rather than content volume**.

The system is designed to support future expansion without restructuring.

---

## 🚀 Key Takeaways

This project demonstrates:

* How **software architecture principles** can be applied in game development
* The benefits of **modular and event-driven design**
* Trade-offs between **complexity and practicality** in real-time systems

---

## 📂 Technologies Used

* Game Engine: Godot 
* Language: *GDScript*

---

## 📌 Author

**Lokesh Satya Kumar**
Bachelor’s Thesis – Computer Science Engineering
University of Pécs

---
