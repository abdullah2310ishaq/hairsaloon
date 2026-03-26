**Here is the COMPLETE detailed breakdown of the Business COMB app**  
(Every module, every screen/page shown in the 15-page PDF, exact functionalities, and full user flows explained step-by-step).

I have organized everything by **Modules** (logical groups) so you can see the big picture + exact screens + what each button/field does + complete user flow.

### 1. Authentication & Onboarding Module
**Screens:** Page 1 (Login) + Page 2 (Business Registration)

**Functionalities:**
- Google (Gmail) single-sign-on
- One-time business setup (only shown if new user)

**Exact User Flow:**
1. Open app → Splash with logo “Business COMB”
2. Tap big green button “Continue with Gmail”
3. Google login completes → App checks if business is already registered
4. If not registered → Directly opens **Business Information** form (Page 2)
   - Business Name
   - Phone number
   - Business Type (dropdown)
   - City (dropdown)
   - Area (dropdown)
   - Full Address
5. Tap green “Register” button → Business is created → User lands on Dashboard (Page 3)

### 2. Dashboard / Home Module
**Screens:** Page 3 (Main Home)

**Functionalities:**
- Quick overview of the entire salon for the day
- Today’s appointments count + quick link
- Shortcut cards to 4 main sections

**User Flow:**
- After registration or login → This is the landing screen every time
- Top green header shows: “Welcome + Salon Name + Address”
- Big “Today Appointments 05” card → Tap “View All” → goes to Appointments tab (not shown in PDF but implied)
- Four clickable cards:
  - Finance → Opens sales/profit reports (Page 14 style)
  - Employees → Opens Employees screen (Page 8)
  - Rate List → Opens Rate List (Page 5)
  - Customers → (Not shown in PDF)
- Bottom navigation always visible: Home | Billing | Expense | Appointment

### 3. Side Menu / Settings Module
**Screens:** Page 4 (Side drawer)

**Functionalities:**
- Quick access to advanced settings
- Logout

**User Flow:**
- Tap hamburger (☰) icon on any screen → Side menu slides in
- Options:
  - Profile Settings
  - Category (manage service categories)
  - Service List (same as Rate List)
  - Expense List (Page 13)
  - Currency Change (typo in app)
  - Tax Rate (used in billing – shown as 17% on Page 7)
- Tap anywhere outside → menu closes

### 4. Rate List / Services Management Module
**Screens:** Page 5 (List) + Page 6 (Add New Service)

**Functionalities:**
- View all services with price, gender, age group
- Add unlimited new services
- Categorised tabs (Men’s Grooming, Skincare, Male, Female, Child, Women)

**Detailed User Flow:**
1. From Home card OR bottom nav OR side menu → “Rate List (09)”
2. See full list (Page 5) – every row shows:
   - Service name
   - Gender + Age group
   - Price (Rs.400 / 600 / 800 etc.)
   - Three-dot menu (probably edit/delete – not opened in PDF)
3. Tap + icon (top right) → “New Service” form opens (Page 6)
   - Select Category (dropdown)
   - Select Service (dropdown – Hair Cut, Shave, etc.)
   - Select Gender
   - Select Age Group
   - Enter Price
4. Tap green “Save Service” → New service added instantly to the list
5. User can switch tabs to filter (Male/Female/Child etc.)

### 5. Billing / POS (Point of Sale) Module
**Screens:** Page 7

**Functionalities:**
- Create bills instantly
- Search/add customer by phone
- Assign employee
- Apply tax automatically
- Multiple services in one bill
- Save bill + payment

**Detailed User Flow (most important module):**
1. Tap “Billing” in bottom navigation
2. Screen shows:
   - Top summary: Sub Total, Tax 17%, Grand Total
   - “Enter Customer Phone Number” field + “Add New” button
   - “Select Employee” dropdown
   - “Payment Type” dropdown
3. Scroll down → “Available Services” grid (4-column cards)
   - Tap any service (Haircut & Blow-dry Rs.1500, Skincare Rs.1500, Shave Rs.400, etc.)
   - Service gets added to the bill (Sub Total updates live)
4. Once services added → Tap “Save Bill” (black button)
5. Bill is saved → Probably prints or shows receipt (not shown in PDF)

### 6. Employees Management Module
**Screens:** Page 8 (List + Add) + Page 9 (Options menu) + Page 10 (Agreement)

**Functionalities:**
- Add employees with full details
- Activate/Deactivate
- Update/Delete
- Create salary + commission agreement per employee

**Complete User Flow:**
1. From Home card OR bottom nav (if available) → Employees (06)
2. Tabs: Active / Deactive / Male / Female
3. Tap + icon → “New Employee” form (Page 8)
   - First Name, Last Name
   - Phone Number
   - CNIC Number
   - Home Address
4. Tap “Save Employee” → Employee appears in list
5. Tap three dots on any employee (Page 9) → Popup:
   - Agreement
   - Update
   - Delete
   - Deactive
6. Tap “Agreement” → Opens Employee Agreement form (Page 10)
   - Select Employee
   - Select Employee Type
   - Basic Salary
   - Commission (%)
   - Description
7. Tap “Save Agreement” → Commission rules are set (used later in salary calculation)

### 7. Expenses Module
**Screens:** Page 11 (Dashboard) + Page 12 (Add Expense) + Page 13 (Expense Types List)

**Functionalities:**
- Track monthly & daily expenses
- Add paid/unpaid expenses
- Categorise expenses (Electricity, Internet, Coffee, etc.)
- Link expenses to employee

**User Flow:**
1. Tap “Expense” in bottom navigation
2. See:
   - Total Monthly Expenses (Rs.75,000)
   - Today Expenses (Rs.5,000)
   - Paid / Unpaid tabs
   - Recent transactions list
3. Tap “Add New Expense” (Page 12 form):
   - Date
   - Select Employee
   - Select Expense Type
   - Amount + Quantity
   - Status (Paid/Unpaid)
   - Payment Type (Cash/Online)
   - Description
4. Tap “Save Expense”
5. Alternative path: Tap gear icon (Settings) → “Expenses List” (Page 13)
   - Add new expense categories (Buy coffee, Electricity, Internet)
   - Enable/disable categories

### 8. Reports & Finance Module
**Screens:** Page 14 (Today Sale & Profit) + Page 15 (Individual Employee Earnings)

**Functionalities:**
- Daily sales, profit, expenses comparison
- Employee-wise today’s earning + due amount
- Settle-up (pay salary/commission)

**User Flow:**
1. Tap Finance card on Home OR view from Billing after saving bill
2. See Page 14:
   - Today Sale Rs.34,400
   - Profit (green) vs Expenses (red)
   - List of every employee’s today earning
3. Tap any employee → Opens detailed view (Page 15)
   - Total Earning
   - Due Amount
   - Daily breakdown table
   - “Settle Up” button (marks as paid)

### 9. Appointments Module
**Mentioned but not deeply shown**
- Bottom navigation has “Appointment”
- Dashboard shows “Today Appointments 05”
- Probably full calendar + booking screen (not included in the 15 pages)

### Overall App Navigation Flow (Complete Journey)
1. Login with Gmail
2. Register business (only first time)
3. Land on Dashboard
4. Main paths:
   - Want to add service? → Rate List
   - Want to bill a customer? → Billing
   - Want to manage staff? → Employees → Agreement
   - Want to record expense? → Expense
   - Want to see today’s profit? → Finance card
   - Quick settings? → Hamburger menu

**Bottom Navigation** is always there:
- Home (Dashboard)
- Billing (POS)
- Expense
- Appointment

This app is a full salon ERP in one mobile app — very complete for Pakistani salons (CNIC, Rs., commission %).
