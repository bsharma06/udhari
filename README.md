# 📒 Finance Ledger App Specification

A **Finance Ledger Application** using **Flutter**. The app should allow users to track money owed and money received, organized by entities or individuals. Below are the detailed requirements:

---

## Home Screen

- Display a **list of unique entities/persons** with their **net balance**:
  - If the user needs to **receive money**, show the amount in **green**.
  - If the user needs to **pay money**, show the amount in **red**.
- At the **top of the screen**, show two summary containers:
  - **Total Receivable** (sum of all amounts to be received).
  - **Total Payable** (sum of all amounts to be paid).
- Include a **floating “Add” button** to create a new transaction.
  - Tapping this button should navigate to the **Transaction Form Screen**.
- Tapping on an **entity/person name** should navigate to the **Detailed Transaction Screen** for that entity, showing all transactions in chronological order and the net balance with that entity.

---

## Detailed Transaction Screen

- Show a **thread of all transactions** with the selected entity/person, ordered by date.
- Each transaction should be tappable:
  - Opens in the **Transaction Form Screen** in **edit/delete mode**.
- Display the **net total** for that entity/person (amount to be received or paid).

---

## Transaction Form Screen

The transaction form should include the following fields and behaviors:

- **Transaction Type**:
  - Two side-by-side toggle buttons: **“To Receive”** or **“To Pay”** (only one can be selected).
- **Amount Field**:
  - Numeric-only input.
- **Payment Date/Time**:
  - Selectable via a **calendar/date-time picker**.
- **Description Field**:
  - Optional, multiline text input.
- **Entity/Person Name Field**:
  - Text input linked to the user’s **contacts**.
  - User can either type a name or select directly from contacts.

---

## Settings Screen

The settings screen should provide the following options:

- **Dark Mode toggle**
- **Refresh Data/Contacts**
- **Export Data**
- **Import Data**
- **About App**
- **Privacy Policy**
- **Contact Us**
- **Rate App**
- **Share App**
- **Logout**

## Tools/Package to be used

- For state management use provider
- For data storage use Sqlite
