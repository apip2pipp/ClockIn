# ClockIn API Documentation

Base URL: `http://127.0.0.1:8000/api`

## Authentication

All protected endpoints require Bearer token in header:
```
Authorization: Bearer {your_token}
```

---

## 📋 API Endpoints

### 1. **Authentication**

#### Register
```http
POST /api/register
Content-Type: application/json

{
    "company_id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "phone": "081234567890",
    "employee_id": "EMP005",
    "position": "Software Engineer"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Registration successful",
    "data": {
        "user": {...},
        "token": "1|xxx...",
        "token_type": "Bearer"
    }
}
```

---

#### Login
```http
POST /api/login
Content-Type: application/json

{
    "email": "budi@example.com",
    "password": "password"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "user": {
            "id": 3,
            "name": "Budi Santoso",
            "email": "budi@example.com",
            "company": {...}
        },
        "token": "2|xxx...",
        "token_type": "Bearer"
    }
}
```

---

#### Logout
```http
POST /api/logout
Authorization: Bearer {token}
```

---

#### Get Profile
```http
GET /api/profile
Authorization: Bearer {token}
```

---

#### Update Profile
```http
PUT /api/profile
Authorization: Bearer {token}
Content-Type: multipart/form-data

name: John Updated
phone: 081234567890
photo: [file]
```

---

### 2. **Company**

#### Get Company Info
```http
GET /api/company
Authorization: Bearer {token}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "PT. Contoh Jaya",
        "email": "company@example.com",
        "latitude": -6.2088,
        "longitude": 106.8456,
        "radius": 100,
        "work_start_time": "08:00:00",
        "work_end_time": "17:00:00"
    }
}
```

---

### 3. **Attendance**

#### Clock In
```http
POST /api/attendance/clock-in
Authorization: Bearer {token}
Content-Type: multipart/form-data

latitude: -6.2088
longitude: 106.8456
photo: [file]
notes: Clock in from office
```

**Response:**
```json
{
    "success": true,
    "message": "Clock in successful",
    "data": {
        "id": 1,
        "user_id": 3,
        "clock_in": "2024-11-11 08:30:00",
        "status": "late",
        ...
    }
}
```

---

#### Clock Out
```http
POST /api/attendance/clock-out
Authorization: Bearer {token}
Content-Type: multipart/form-data

latitude: -6.2088
longitude: 106.8456
photo: [file]
notes: Clock out from office
```

---

#### Get Today's Attendance
```http
GET /api/attendance/today
Authorization: Bearer {token}
```

---

#### Get Attendance History
```http
GET /api/attendance/history?page=1&per_page=15&month=11&year=2024
Authorization: Bearer {token}
```

---

#### Get Attendance Statistics
```http
GET /api/attendance/statistics?month=11&year=2024
Authorization: Bearer {token}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "total_days": 15,
        "on_time": 10,
        "late": 5,
        "half_day": 0,
        "absent": 0,
        "total_work_hours": 120.5
    }
}
```

---

### 4. **Leave Requests**

#### Get Leave Requests
```http
GET /api/leave-requests?status=pending&page=1
Authorization: Bearer {token}
```

---

#### Submit Leave Request
```http
POST /api/leave-requests
Authorization: Bearer {token}
Content-Type: multipart/form-data

type: sick
start_date: 2024-11-15
end_date: 2024-11-17
reason: Flu and fever
attachment: [file] (optional)
```

**Response:**
```json
{
    "success": true,
    "message": "Leave request submitted successfully",
    "data": {
        "id": 1,
        "type": "sick",
        "start_date": "2024-11-15",
        "end_date": "2024-11-17",
        "total_days": 3,
        "status": "pending"
    }
}
```

---

#### Get Leave Request Detail
```http
GET /api/leave-requests/{id}
Authorization: Bearer {token}
```

---

#### Cancel Leave Request
```http
DELETE /api/leave-requests/{id}
Authorization: Bearer {token}
```

---

#### Get Leave Statistics
```http
GET /api/leave-requests/statistics/summary?year=2024
Authorization: Bearer {token}
```

---

## 📝 Testing Credentials

Use these credentials for testing:

### Employee Account
```
Email: budi@example.com
Password: password
Company ID: 1
```

### Company Info (for GPS testing)
```
Latitude: -6.2088
Longitude: 106.8456
Radius: 100 meters
```

---

## ⚠️ Error Responses

### Validation Error (422)
```json
{
    "success": false,
    "message": "Validation error",
    "errors": {
        "email": ["The email field is required."]
    }
}
```

### Unauthorized (401)
```json
{
    "success": false,
    "message": "Unauthenticated."
}
```

### GPS Out of Range (400)
```json
{
    "success": false,
    "message": "You are not within the office location. Distance: 250 meters",
    "data": {
        "distance": 250,
        "max_radius": 100
    }
}
```

---

## 🧪 Testing with cURL

### Login Example
```bash
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "budi@example.com",
    "password": "password"
  }'
```

### Clock In Example
```bash
curl -X POST http://127.0.0.1:8000/api/attendance/clock-in \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "latitude=-6.2088" \
  -F "longitude=106.8456" \
  -F "photo=@/path/to/photo.jpg" \
  -F "notes=Clock in from office"
```

---

## 📱 Ready for Flutter Integration!

All endpoints are ready to be consumed by your Flutter application.
