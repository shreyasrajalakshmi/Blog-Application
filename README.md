# Blog Application: Django REST + Flutter Web

This project is a full-stack blog application with a Django REST Framework backend and a Flutter web frontend.

## Features
- User authentication (JWT)
- View list of blog posts
- Read individual blog posts
- Create new blog posts (authenticated users)

## Project Structure
```
Blog application/
├── django/      # Django backend (API)
└── flutter/     # Flutter web frontend
```

## Getting Started

### Backend (Django)
1. Navigate to the `django` folder:
   ```sh
   cd django
   ```
2. Install dependencies:
   ```sh
   pip install -r requirements.txt
   ```
3. Run migrations:
   ```sh
   python manage.py migrate
   ```
4. Create a superuser (optional, for admin):
   ```sh
   python manage.py createsuperuser
   ```
5. Start the server:
   ```sh
   python manage.py runserver
   ```
   The API will be available at `http://localhost:8000/`

### Frontend (Flutter Web)
1. Navigate to the Flutter web project:
   ```sh
   cd flutter/blog_web
   ```
2. Get dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run -d chrome
   ```
   The app will open in your browser (check the terminal for the exact URL).

## Usage
- Login with your Django credentials.
- View, read, and create blog posts from the web interface.

---

