# Product CRUD App UI

![Image](https://github.com/user-attachments/assets/a6c88868-93ac-4465-ae06-086a4b11b622)

# Product CRUD App

![Product CRUD App](https://img.shields.io/badge/Flutter-3.19-blue?logo=flutter)
![Node.js](https://img.shields.io/badge/Node.js-18.x-green?logo=node.js)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange?logo=mysql)

A full-stack Product Management System with Flutter frontend, Node.js/Express backend, and MySQL database.

- 📦 **Backend**: Node.js + Express
- 📱 **Frontend**: Flutter App
- 🗃️ **Database**: MySQL
- **API Format:** RESTful JSON API

## Table of Contents
- [Features](#-features)
- [Project Structure](#-project-structure)
- [Screenshots](#-screenshots)

---

## 🌟 Features
- **Full CRUD Operations**:
  - Create, Read, Update, and Delete products
- **Modern UI**:
  - Responsive Flutter interface
- **State Management**:
  - Provider pattern for efficient state handling
- **RESTful API**:
  - RESTful API integration
  - Proper error handling

---

## 📁 Folder Structure

- `/backend`: RESTful API (Express)
- `/frontend`: Flutter mobile application
  
---

📄 API Endpoints

| Method | Endpoint           | Description          |
| ------ | ------------------ | -------------------- |
| GET    | /api/products      | Get all products     |
| POST   | /api/products      | Create a new product |
| PUT    | /api/products/\:id | Update a product     |
| DELETE | /api/products/\:id | Delete a product     |


---

# 📱 Flutter Frontend - Product CRUD App

This is the mobile frontend for the Product CRUD application, built using **Flutter**.

It connects to a RESTful API built with Node.js and Express.
---
### 1. Clone the Repository

```bash
git clone https://github.com/Sengleang99/product-crud-app.git
cd product-crud-app
