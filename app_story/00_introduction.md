# Chapter 0: The Prologue — What Are We Building?

Welcome to the story of **Sellio Categories Section Controller** — a real-world Flutter application built from the ground up using professional software engineering practices.

---

## The Problem

Imagine you work at an e-commerce company called **Sellio**. The app has a Home Screen that shows different product sections like "Electronics", "Fashion", "Home & Kitchen". Someone needs to **manage** these sections — create new ones, change their order, turn them on/off, and delete them.

That "someone" is the **Admin**. And this app is the **Admin Panel** they use.

## What Does This App Actually Do?

Here's the full feature list:

| Feature            | What It Means                                             |
| ------------------ | --------------------------------------------------------- |
| **View Sections**  | See all home screen sections in a list                    |
| **Add Section**    | Create a new section linked to a product category         |
| **Edit Section**   | Change the title, category, or display order              |
| **Toggle Active**  | Turn a section on/off without deleting it                 |
| **Delete Section** | Permanently remove a section                              |
| **Optimistic UI**  | Changes appear instantly, even before the server responds |

## The Tech Stack

Before we dive in, here's what tools and packages we use:

```
🎯 Flutter (Dart)          → The framework for building the UI
🌐 Dio                     → HTTP client for talking to the server
🔌 Retrofit                → Generates type-safe API calls automatically
📦 json_serializable       → Converts JSON ↔ Dart objects automatically
🧱 flutter_bloc (Cubit)    → State management (the brain of the UI)
💉 GetIt + Injectable      → Dependency Injection (the wiring)
🔄 build_runner            → Code generation tool
```

## The Architecture

We follow **Clean Architecture**, which splits the code into 3 layers:

```
┌─────────────────────────────────┐
│     PRESENTATION LAYER          │  ← What you SEE (UI + Cubit)
│     (Screens, Cubits, Theme)    │
├─────────────────────────────────┤
│     DOMAIN LAYER                │  ← What the app DOES (Business Logic)
│     (Entities, Use Cases, Repos)│
├─────────────────────────────────┤
│     DATA LAYER                  │  ← Where data COMES FROM (API, Models)
│     (Models, Mappers, API, DSs) │
└─────────────────────────────────┘
```

**Why 3 layers?** Because if you change how you talk to the server (Data), you don't need to change the UI (Presentation). And if you change the UI, you don't need to touch the business rules (Domain). Each layer is independent.

## How to Read This Story

Each chapter builds on the previous one. We start from the very bottom (the data that flows through the app) and work our way up to what the user sees on screen.

| Chapter | Title          | What You'll Learn                       |
| ------- | -------------- | --------------------------------------- |
| 1       | The Foundation | Entities — the core data structures     |
| 2       | The Translator | Models — converting JSON to Dart        |
| 3       | The Messenger  | API & Networking with Retrofit          |
| 3.5     | The Bridge     | Mappers — connecting Models to Entities |
| 4       | The Rulebook   | Repositories & Use Cases                |
| 5       | The Wiring     | Dependency Injection with GetIt         |
| 6       | The Brain      | State Management with Cubit             |
| 7       | The Face       | Building the UI                         |

Let's begin!
