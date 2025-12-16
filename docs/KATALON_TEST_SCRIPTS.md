# 🎭 Katalon Test Scripts - ClockIn Admin Panel

> Sample test scripts untuk Katalon Studio

---

## 📁 Project Structure

```
KatalonProject/
├── Test Cases/
│   ├── Authentication/
│   ├── UserManagement/
│   ├── AttendanceManagement/
│   └── LeaveRequestManagement/
├── Object Repository/
│   ├── Pages/
│   └── Elements/
├── Test Suites/
└── Profiles/
```

---

## 🔐 1. Authentication Tests

### **TC_Admin_Login_Success**

```groovy
import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI
import com.kms.katalon.core.model.FailureHandling as FailureHandling

// Navigate to admin login page
WebUI.openBrowser('')
WebUI.navigateToUrl('http://localhost/admin/login')

// Wait for page to load
WebUI.waitForPageLoad(10)

// Enter email
WebUI.setText(findTestObject('Object Repository/Pages/LoginPage/input_Email'), 
    'admin@clockin.com')

// Enter password
WebUI.setText(findTestObject('Object Repository/Pages/LoginPage/input_Password'), 
    'password')

// Click login button
WebUI.click(findTestObject('Object Repository/Pages/LoginPage/button_Login'))

// Verify redirect to dashboard
WebUI.verifyElementPresent(findTestObject('Object Repository/Pages/DashboardPage/title_Dashboard'), 
    10, 
    FailureHandling.STOP_ON_FAILURE)

// Verify URL contains /admin
WebUI.verifyMatch(WebUI.getUrl(), '.*/admin.*', true)

WebUI.closeBrowser()
```

### **TC_Admin_Login_Invalid**

```groovy
import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI

WebUI.openBrowser('')
WebUI.navigateToUrl('http://localhost/admin/login')

WebUI.setText(findTestObject('Object Repository/Pages/LoginPage/input_Email'), 
    'wrong@email.com')
WebUI.setText(findTestObject('Object Repository/Pages/LoginPage/input_Password'), 
    'wrongpassword')

WebUI.click(findTestObject('Object Repository/Pages/LoginPage/button_Login'))

// Verify error message displayed
WebUI.verifyElementPresent(findTestObject('Object Repository/Pages/LoginPage/text_ErrorMessage'), 
    5)

// Verify still on login page
WebUI.verifyMatch(WebUI.getUrl(), '.*/login.*', true)

WebUI.closeBrowser()
```

---

## 👥 2. User Management Tests

### **TC_Create_Employee**

```groovy
import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI
import com.kms.katalon.core.util.KeywordUtil

// Login first (reusable keyword)
CustomKeywords.'com.clockin.keywords.LoginKeywords.loginAsAdmin'()

// Navigate to Employees
WebUI.click(findTestObject('Object Repository/Pages/DashboardPage/menu_Employees'))

// Click New Employee button
WebUI.click(findTestObject('Object Repository/Pages/EmployeeListPage/button_NewEmployee'))

// Fill form
WebUI.setText(findTestObject('Object Repository/Pages/EmployeeFormPage/input_Name'), 
    'Test Employee')
WebUI.setText(findTestObject('Object Repository/Pages/EmployeeFormPage/input_Email'), 
    'test.employee@test.com')
WebUI.selectOptionByLabel(findTestObject('Object Repository/Pages/EmployeeFormPage/select_Company'), 
    'Test Company', false)
WebUI.setText(findTestObject('Object Repository/Pages/EmployeeFormPage/input_EmployeeID'), 
    'TEST001')
WebUI.setText(findTestObject('Object Repository/Pages/EmployeeFormPage/input_Password'), 
    'password123')
WebUI.setText(findTestObject('Object Repository/Pages/EmployeeFormPage/input_PasswordConfirmation'), 
    'password123')

// Submit form
WebUI.click(findTestObject('Object Repository/Pages/EmployeeFormPage/button_Create'))

// Verify success notification
WebUI.verifyElementPresent(findTestObject('Object Repository/Elements/notification_Success'), 
    5)

// Verify employee in list
WebUI.verifyElementText(findTestObject('Object Repository/Pages/EmployeeListPage/text_EmployeeName'), 
    'Test Employee')

WebUI.closeBrowser()
```

### **TC_Search_Employee**

```groovy
import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI

CustomKeywords.'com.clockin.keywords.LoginKeywords.loginAsAdmin'()

WebUI.click(findTestObject('Object Repository/Pages/DashboardPage/menu_Employees'))

// Enter search term
WebUI.setText(findTestObject('Object Repository/Pages/EmployeeListPage/input_Search'), 
    'John Doe')

// Wait for results
WebUI.delay(2)

// Verify filtered results
WebUI.verifyElementText(findTestObject('Object Repository/Pages/EmployeeListPage/text_FirstEmployeeName'), 
    'John Doe')

WebUI.closeBrowser()
```

---

## ⏰ 3. Attendance Management Tests

### **TC_View_Attendance_List**

```groovy
import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI

CustomKeywords.'com.clockin.keywords.LoginKeywords.loginAsAdmin'()

// Navigate to Attendances
WebUI.click(findTestObject('Object Repository/Pages/DashboardPage/menu_Attendances'))

// Verify table is displayed
WebUI.verifyElementPresent(findTestObject('Object Repository/Pages/AttendanceListPage/table_Attendances'), 
    10)

// Verify table headers
WebUI.verifyElementPresent(findTestObject('Object Repository/Pages/AttendanceListPage/header_Employee'), 
    5)
WebUI.verifyElementPresent(findTestObject('Object Repository/Pages/AttendanceListPage/header_ClockIn'), 
    5)
WebUI.verifyElementPresent(findTestObject('Object Repository/Pages/AttendanceListPage/header_Status'), 
    5)

WebUI.closeBrowser()
```

### **TC_Filter_Attendance_By_Date**

```groovy
import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI

CustomKeywords.'com.clockin.keywords.LoginKeywords.loginAsAdmin'()

WebUI.click(findTestObject('Object Repository/Pages/DashboardPage/menu_Attendances'))

// Click filter button
WebUI.click(findTestObject('Object Repository/Pages/AttendanceListPage/button_Filter'))

// Select date range
WebUI.setText(findTestObject('Object Repository/Pages/AttendanceListPage/input_StartDate'), 
    '2024-12-01')
WebUI.setText(findTestObject('Object Repository/Pages/AttendanceListPage/input_EndDate'), 
    '2024-12-31')

// Apply filter
WebUI.click(findTestObject('Object Repository/Pages/AttendanceListPage/button_ApplyFilter'))

// Wait for filtered results
WebUI.delay(2)

// Verify results are filtered
WebUI.verifyElementPresent(findTestObject('Object Repository/Pages/AttendanceListPage/table_Attendances'), 
    5)

WebUI.closeBrowser()
```

### **TC_Export_Attendance_To_Excel**

```groovy
import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI
import com.kms.katalon.core.configuration.RunConfiguration

CustomKeywords.'com.clockin.keywords.LoginKeywords.loginAsAdmin'()

WebUI.click(findTestObject('Object Repository/Pages/DashboardPage/menu_Attendances'))

// Click export button
WebUI.click(findTestObject('Object Repository/Pages/AttendanceListPage/button_Export'))

// Wait for download
WebUI.delay(5)

// Verify file downloaded (check download folder)
String downloadPath = RunConfiguration.getProjectDir() + '/Downloads'
File downloadFolder = new File(downloadPath)
File[] files = downloadFolder.listFiles()

boolean fileFound = false
for (File file : files) {
    if (file.getName().contains('attendance') && file.getName().endsWith('.xlsx')) {
        fileFound = true
        break
    }
}

WebUI.verifyEqual(fileFound, true, FailureHandling.STOP_ON_FAILURE)

WebUI.closeBrowser()
```

---

## 📝 4. Leave Request Management Tests

### **TC_Approve_Leave_Request**

```groovy
import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI

CustomKeywords.'com.clockin.keywords.LoginKeywords.loginAsAdmin'()

// Navigate to Leave Requests
WebUI.click(findTestObject('Object Repository/Pages/DashboardPage/menu_LeaveRequests'))

// Filter by pending status
WebUI.click(findTestObject('Object Repository/Pages/LeaveRequestListPage/button_Filter'))
WebUI.selectOptionByLabel(findTestObject('Object Repository/Pages/LeaveRequestListPage/select_Status'), 
    'pending', false)
WebUI.click(findTestObject('Object Repository/Pages/LeaveRequestListPage/button_ApplyFilter'))

// Wait for results
WebUI.delay(2)

// Click on first pending request
WebUI.click(findTestObject('Object Repository/Pages/LeaveRequestListPage/row_FirstPendingRequest'))

// Click approve button
WebUI.click(findTestObject('Object Repository/Pages/LeaveRequestDetailPage/button_Approve'))

// Confirm approval
WebUI.click(findTestObject('Object Repository/Elements/modal_ConfirmButton'))

// Verify success notification
WebUI.verifyElementPresent(findTestObject('Object Repository/Elements/notification_Success'), 
    5)

// Verify status changed
WebUI.verifyElementText(findTestObject('Object Repository/Pages/LeaveRequestDetailPage/text_Status'), 
    'approved')

WebUI.closeBrowser()
```

### **TC_Reject_Leave_Request**

```groovy
import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI

CustomKeywords.'com.clockin.keywords.LoginKeywords.loginAsAdmin'()

WebUI.click(findTestObject('Object Repository/Pages/DashboardPage/menu_LeaveRequests'))

// Filter by pending
WebUI.click(findTestObject('Object Repository/Pages/LeaveRequestListPage/button_Filter'))
WebUI.selectOptionByLabel(findTestObject('Object Repository/Pages/LeaveRequestListPage/select_Status'), 
    'pending', false)
WebUI.click(findTestObject('Object Repository/Pages/LeaveRequestListPage/button_ApplyFilter'))

WebUI.delay(2)

// Click on first pending request
WebUI.click(findTestObject('Object Repository/Pages/LeaveRequestListPage/row_FirstPendingRequest'))

// Click reject button
WebUI.click(findTestObject('Object Repository/Pages/LeaveRequestDetailPage/button_Reject'))

// Enter rejection reason
WebUI.setText(findTestObject('Object Repository/Pages/LeaveRequestDetailPage/textarea_RejectionReason'), 
    'Insufficient leave balance')

// Confirm rejection
WebUI.click(findTestObject('Object Repository/Elements/modal_ConfirmButton'))

// Verify success
WebUI.verifyElementPresent(findTestObject('Object Repository/Elements/notification_Success'), 
    5)

// Verify status changed
WebUI.verifyElementText(findTestObject('Object Repository/Pages/LeaveRequestDetailPage/text_Status'), 
    'rejected')

WebUI.closeBrowser()
```

---

## 🔧 Reusable Keywords

### **LoginKeywords.groovy**

```groovy
package com.clockin.keywords

import com.kms.katalon.core.webui.keyword.WebUiBuiltInKeywords as WebUI

public class LoginKeywords {
    
    /**
     * Login as admin user
     */
    public static void loginAsAdmin() {
        WebUI.openBrowser('')
        WebUI.navigateToUrl('http://localhost/admin/login')
        WebUI.waitForPageLoad(10)
        
        WebUI.setText(findTestObject('Object Repository/Pages/LoginPage/input_Email'), 
            'admin@clockin.com')
        WebUI.setText(findTestObject('Object Repository/Pages/LoginPage/input_Password'), 
            'password')
        
        WebUI.click(findTestObject('Object Repository/Pages/LoginPage/button_Login'))
        WebUI.waitForPageLoad(10)
    }
    
    /**
     * Logout from admin panel
     */
    public static void logout() {
        WebUI.click(findTestObject('Object Repository/Pages/DashboardPage/button_Logout'))
        WebUI.waitForPageLoad(5)
    }
}
```

---

## 📊 Test Data Files

### **test_data.csv**

```csv
email,password,role,expected_result
admin@clockin.com,password,admin,success
wrong@email.com,wrongpass,admin,failure
test@test.com,password,employee,success
```

### **employee_data.csv**

```csv
name,email,employee_id,company,position
John Doe,john.doe@test.com,EMP001,Company A,Developer
Jane Smith,jane.smith@test.com,EMP002,Company A,Designer
Bob Wilson,bob.wilson@test.com,EMP003,Company B,Manager
```

---

## 🎯 Best Practices

1. **Use Object Repository** - Jangan hardcode XPath/CSS
2. **Create Reusable Keywords** - Untuk login, logout, dll
3. **Data-Driven Testing** - Gunakan CSV/Excel untuk test data
4. **Wait Strategies** - Gunakan explicit waits
5. **Screenshot on Failure** - Otomatis capture saat gagal
6. **Page Object Model** - Organize by pages
7. **Test Suites** - Group related tests

---

## 🚀 Execution

### **Run Single Test:**
```
Right-click test case → Run
```

### **Run Test Suite:**
```
Right-click test suite → Run
```

### **Run from Command Line:**
```bash
katalon -noSplash -runMode=console \
  -projectPath="KatalonProject" \
  -testSuitePath="Test Suites/TS_Full_Admin_Flow" \
  -executionProfile="Chrome"
```

---

**Last Updated:** December 2024  
**Status:** 📋 Template Ready for Implementation



