# 🎭 E2E Testing Plan - ClockIn Web Admin Panel

> End-to-End Testing Plan using Katalon Studio for Filament Admin Panel

---

## 🎯 Overview

**Tool:** Katalon Studio  
**Target:** Filament Admin Panel (Web)  
**Focus:** 3 Core Features + Admin Management

---

## 📋 Test Scenarios

### 🔐 **1. Admin Authentication Flow**

#### **Test Cases:**

| Test ID | Scenario | Steps | Expected Result |
|---------|----------|-------|-----------------|
| E2E-AUTH-01 | Admin Login Success | 1. Navigate to `/admin/login`<br>2. Enter valid admin credentials<br>3. Click Login | Redirected to dashboard |
| E2E-AUTH-02 | Admin Login Invalid | 1. Navigate to `/admin/login`<br>2. Enter invalid credentials<br>3. Click Login | Error message displayed |
| E2E-AUTH-03 | Admin Logout | 1. Login as admin<br>2. Click logout button<br>3. Confirm logout | Redirected to login page |
| E2E-AUTH-04 | Session Timeout | 1. Login as admin<br>2. Wait for session timeout<br>3. Try to access protected page | Redirected to login |

**Priority:** 🔴 High

---

### 👥 **2. User/Employee Management**

#### **Test Cases:**

| Test ID | Scenario | Steps | Expected Result |
|---------|----------|-------|-----------------|
| E2E-USER-01 | View Employee List | 1. Login as admin<br>2. Navigate to Employees<br>3. View list | Employee table displayed |
| E2E-USER-02 | Create New Employee | 1. Click "New Employee"<br>2. Fill all required fields<br>3. Select company<br>4. Submit | Employee created, shown in list |
| E2E-USER-03 | Edit Employee | 1. Click edit on employee<br>2. Update name/email<br>3. Save | Changes saved, updated in list |
| E2E-USER-04 | View Employee Details | 1. Click on employee row<br>2. View details page | All employee info displayed |
| E2E-USER-05 | Search Employee | 1. Use search box<br>2. Type employee name<br>3. View results | Filtered results shown |
| E2E-USER-06 | Filter by Company | 1. Use filter dropdown<br>2. Select company<br>3. View results | Only employees from company shown |
| E2E-USER-07 | Delete Employee | 1. Click delete on employee<br>2. Confirm deletion | Employee removed from list |

**Priority:** 🔴 High

---

### ⏰ **3. Attendance Management**

#### **Test Cases:**

| Test ID | Scenario | Steps | Expected Result |
|---------|----------|-------|-----------------|
| E2E-ATT-01 | View Attendance List | 1. Navigate to Attendances<br>2. View list | Attendance table displayed |
| E2E-ATT-02 | Filter by Date Range | 1. Use date filter<br>2. Select start & end date<br>3. Apply filter | Filtered attendances shown |
| E2E-ATT-03 | Filter by Employee | 1. Use employee filter<br>2. Select employee<br>3. Apply | Only selected employee's attendance |
| E2E-ATT-04 | Filter by Status | 1. Use status filter<br>2. Select status (on_time/late)<br>3. Apply | Filtered by status |
| E2E-ATT-05 | View Attendance Details | 1. Click on attendance row<br>2. View details | Clock in/out times, photos, GPS shown |
| E2E-ATT-06 | Export to Excel | 1. Click export button<br>2. Download file | Excel file downloaded |
| E2E-ATT-07 | Validate Attendance | 1. View attendance<br>2. Click validate<br>3. Set status (valid/invalid) | Status updated |
| E2E-ATT-08 | View Attendance Photos | 1. Open attendance details<br>2. Click on photo | Photo displayed in modal |

**Priority:** 🔴 High

---

### 📝 **4. Leave Request Management**

#### **Test Cases:**

| Test ID | Scenario | Steps | Expected Result |
|---------|----------|-------|-----------------|
| E2E-LEAVE-01 | View Leave Requests | 1. Navigate to Leave Requests<br>2. View list | All leave requests displayed |
| E2E-LEAVE-02 | Filter by Status | 1. Use status filter<br>2. Select "pending"<br>3. Apply | Only pending requests shown |
| E2E-LEAVE-03 | Approve Leave Request | 1. Find pending request<br>2. Click approve button<br>3. Confirm | Status changed to approved |
| E2E-LEAVE-04 | Reject Leave Request | 1. Find pending request<br>2. Click reject button<br>3. Enter reason<br>4. Confirm | Status changed to rejected |
| E2E-LEAVE-05 | View Leave Details | 1. Click on leave request<br>2. View details | All info displayed (dates, reason, attachment) |
| E2E-LEAVE-06 | Download Attachment | 1. Open leave request<br>2. Click attachment link | File downloaded |
| E2E-LEAVE-07 | Filter by Employee | 1. Use employee filter<br>2. Select employee | Only that employee's requests |
| E2E-LEAVE-08 | Filter by Type | 1. Use type filter<br>2. Select type (sick/annual) | Filtered by type |

**Priority:** 🔴 High

---

### 🏢 **5. Company Management**

| Test ID | Scenario | Steps | Expected Result |
|---------|----------|-------|-----------------|
| E2E-COMP-01 | View Company List | 1. Navigate to Companies<br>2. View list | All companies displayed |
| E2E-COMP-02 | View Company Details | 1. Click on company<br>2. View details | Company info, location, settings shown |
| E2E-COMP-03 | Edit Company | 1. Click edit<br>2. Update work hours<br>3. Save | Changes saved |
| E2E-COMP-04 | View Company Location | 1. Open company details<br>2. Click map link | Google Maps opened |

**Priority:** 🟡 Medium

---

## 🛠️ Katalon Test Structure

```
KatalonProject/
├── Test Cases/
│   ├── Authentication/
│   │   ├── TC_Admin_Login_Success
│   │   ├── TC_Admin_Login_Invalid
│   │   ├── TC_Admin_Logout
│   │   └── TC_Session_Timeout
│   ├── UserManagement/
│   │   ├── TC_View_Employee_List
│   │   ├── TC_Create_Employee
│   │   ├── TC_Edit_Employee
│   │   ├── TC_View_Employee_Details
│   │   ├── TC_Search_Employee
│   │   ├── TC_Filter_By_Company
│   │   └── TC_Delete_Employee
│   ├── AttendanceManagement/
│   │   ├── TC_View_Attendance_List
│   │   ├── TC_Filter_By_Date
│   │   ├── TC_Filter_By_Employee
│   │   ├── TC_Filter_By_Status
│   │   ├── TC_View_Attendance_Details
│   │   ├── TC_Export_To_Excel
│   │   ├── TC_Validate_Attendance
│   │   └── TC_View_Attendance_Photos
│   ├── LeaveRequestManagement/
│   │   ├── TC_View_Leave_Requests
│   │   ├── TC_Filter_By_Status
│   │   ├── TC_Approve_Leave_Request
│   │   ├── TC_Reject_Leave_Request
│   │   ├── TC_View_Leave_Details
│   │   ├── TC_Download_Attachment
│   │   ├── TC_Filter_By_Employee
│   │   └── TC_Filter_By_Type
│   └── CompanyManagement/
│       ├── TC_View_Company_List
│       ├── TC_View_Company_Details
│       ├── TC_Edit_Company
│       └── TC_View_Company_Location
├── Object Repository/
│   ├── Pages/
│   │   ├── LoginPage
│   │   ├── DashboardPage
│   │   ├── EmployeeListPage
│   │   ├── EmployeeFormPage
│   │   ├── AttendanceListPage
│   │   ├── AttendanceDetailPage
│   │   ├── LeaveRequestListPage
│   │   ├── LeaveRequestDetailPage
│   │   └── CompanyListPage
│   └── Elements/
│       ├── Buttons
│       ├── Inputs
│       ├── Tables
│       └── Modals
├── Test Suites/
│   ├── TS_Authentication
│   ├── TS_UserManagement
│   ├── TS_AttendanceManagement
│   ├── TS_LeaveRequestManagement
│   └── TS_Full_Admin_Flow
└── Profiles/
    ├── Chrome
    ├── Firefox
    └── Edge
```

---

## 📝 Test Data Setup

### **Test Users:**
```json
{
  "admin": {
    "email": "admin@clockin.com",
    "password": "password",
    "role": "admin"
  },
  "test_employee": {
    "name": "Test Employee",
    "email": "test.employee@test.com",
    "employee_id": "TEST001"
  }
}
```

### **Test Companies:**
- Company A (for testing)
- Company B (for testing)

---

## 🎯 Priority Test Scenarios

### **Phase 1: Critical Paths (Must Have)**
1. ✅ Admin Login
2. ✅ View Employee List
3. ✅ Create Employee
4. ✅ View Attendance List
5. ✅ Approve Leave Request
6. ✅ Reject Leave Request

### **Phase 2: Important Features (Should Have)**
1. Edit Employee
2. Filter Attendances
3. Export Attendance
4. View Leave Details
5. Filter Leave Requests

### **Phase 3: Nice to Have**
1. Company Management
2. Advanced Filters
3. Bulk Operations

---

## 🔧 Katalon Configuration

### **Browser Settings:**
- Primary: Chrome (Headless mode for CI/CD)
- Secondary: Firefox, Edge

### **Wait Strategy:**
- Implicit Wait: 10 seconds
- Explicit Wait: For dynamic elements
- Fluent Wait: For AJAX calls

### **Screenshot:**
- On failure: ✅ Enabled
- On success: ⚠️ Optional

### **Video Recording:**
- On failure: ✅ Enabled
- Format: MP4

---

## 📊 Expected Test Results

| Module | Test Cases | Priority |
|--------|-----------|----------|
| Authentication | 4 | 🔴 High |
| User Management | 7 | 🔴 High |
| Attendance Management | 8 | 🔴 High |
| Leave Request Management | 8 | 🔴 High |
| Company Management | 4 | 🟡 Medium |
| **TOTAL** | **31** | |

---

## 🚀 Execution Plan

### **Manual Execution:**
1. Open Katalon Studio
2. Select test suite
3. Run test cases
4. Review results

### **CI/CD Integration:**
```bash
# Run Katalon tests in CI/CD
katalon -noSplash -runMode=console \
  -projectPath="KatalonProject" \
  -retry=0 \
  -testSuitePath="Test Suites/TS_Full_Admin_Flow" \
  -executionProfile="Chrome" \
  -apiKey="YOUR_API_KEY"
```

---

## 📝 Test Scripts Template

### **Login Test Example:**
```groovy
import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI

// Navigate to login page
WebUI.openBrowser('http://localhost/admin/login')

// Enter credentials
WebUI.setText(findTestObject('LoginPage/input_Email'), 'admin@clockin.com')
WebUI.setText(findTestObject('LoginPage/input_Password'), 'password')

// Click login
WebUI.click(findTestObject('LoginPage/button_Login'))

// Verify redirect to dashboard
WebUI.verifyElementPresent(findTestObject('DashboardPage/title_Dashboard'), 10)
```

---

## ✅ Success Criteria

- ✅ All critical paths tested
- ✅ 90%+ test pass rate
- ✅ Screenshots on failure
- ✅ Test execution time < 30 minutes
- ✅ Reusable test objects
- ✅ Data-driven testing where applicable

---

---

## 📝 Implementation Checklist

### **Setup Phase:**
- [ ] Install Katalon Studio
- [ ] Create new Katalon project
- [ ] Configure browser drivers (Chrome, Firefox, Edge)
- [ ] Setup Object Repository structure
- [ ] Create test data files (CSV/Excel)

### **Development Phase:**
- [ ] Create page objects in Object Repository
- [ ] Create reusable keywords (LoginKeywords, etc.)
- [ ] Implement Phase 1 test cases (Critical paths)
- [ ] Implement Phase 2 test cases (Important features)
- [ ] Implement Phase 3 test cases (Nice to have)

### **Testing Phase:**
- [ ] Run all test cases
- [ ] Fix any failures
- [ ] Verify screenshots on failure
- [ ] Review test execution time
- [ ] Document any issues found

### **CI/CD Integration:**
- [ ] Setup Katalon in CI/CD pipeline
- [ ] Configure headless execution
- [ ] Setup test reports
- [ ] Configure notifications

---

## 🔗 Useful Resources

- [Katalon Studio Documentation](https://docs.katalon.com/)
- [Katalon Academy](https://academy.katalon.com/)
- [Filament Documentation](https://filamentphp.com/docs)
- [Test Scripts Template](./KATALON_TEST_SCRIPTS.md)

---

**Last Updated:** December 2024  
**Status:** 📋 Test Plan Ready for Implementation  
**Estimated Implementation:** 7-10 days

