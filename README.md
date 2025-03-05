# Hands-On Challenge

## Interview Tasks

### Task 1: Flow and Subflow

#### Requirement Overview
Implement a solution in Salesforce using Flow and Sub-flow to automatically populate the **First Approver, Second Approver, and Third Approver** fields on a **Quote** record when it is created. The approvers will be determined based on specific conditions by comparing the **Account Country** and **Opportunity Type** fields with records in the **Approval Matrices** object.

#### Objects Involved
1. **Quote**
   - Fields:
     - Approver 1: Lookup field to the Custom User object
     - Approver 2: Lookup field to the Custom User object
     - Approver 3: Lookup field to the Custom User object

2. **Approval Matrices** (Custom Object)
   - Fields:
     - First-Level Approver: Lookup field to the User object
     - Second-Level Approver: Lookup field to the User object
     - Third-Level Approver: Lookup field to the User object
     - Account Country: Picklist (5 random countries)
     - Opportunity Type: Picklist with the following values:
       - New Business – New Customer
       - New Business – Existing Customer
       - Existing Business - Additional Order
       - Existing Business - Change Existing Order

3. **User** (Custom Object)
   - Fields:
     - First Name
     - Last Name
     - Email
   - Create 3-4 records for approvers.

4. **Account**
   - Fields:
     - Account Country (Picklist with same values as Approval Matrices)

5. **Opportunity**
   - Fields:
     - Opportunity Type (Picklist with same values as Approval Matrices)

#### Sample Records in Approval Matrices
| Account Country | Opportunity Type                       | First Level Approver | Second Level Approver | Third Level Approver |
|-----------------|--------------------------------------|----------------------|----------------------|----------------------|
| India          | New Business – New Customer         | User 1               | User 2               | User 3               |
| India          | Existing Business - Additional Order | User 2               | User 1               | User 3               |
| USA            | Existing Business - Change Existing Order | User 4         | User 5               | User 6               |
| UK             | New Business – Existing Customer     | User 3               | User 5               | User 6               |

#### Flow Implementation
- **Main Flow**: Triggers when a **Quote** is created.
- **Sub-flow**: Encapsulates logic for fetching approvers based on conditions to ensure reusability.

---

### Task 2: Apex Trigger

#### Field Requirements
1. **Contact Object**
   - Annual Revenue: Currency field
   - Country: Single-select picklist
   - State: Single-select picklist
   - IsActive: Checkbox (Boolean field)

2. **Account Object**
   - Country: Single-select picklist
   - State: Multi-select picklist
   - Total Annual Revenue: Currency field

#### Functional Requirements
1. **Field Dependencies**
   - Country on **Contact**: Automatically populated from the related **Account** and must be read-only.
   - State on **Contact**: Should display only states corresponding to the selected country.

2. **State Rollup to Account**
   - For all **Active Contacts** (IsActive = true), retrieve their **State** values and update the **Account's State** multi-select picklist.

3. **Annual Revenue Calculation**
   - Sum the **Annual Revenue** of all **Active Contacts** (IsActive = true) and populate the **Account's Total Annual Revenue** field.

#### Trigger Requirements
- Execute on **Insert, Update, and Delete** events on **Contact**.
- Handle bulk records efficiently using **maps, sets, and collections** to stay within governor limits.

---

### Task 3: Lightning Web Component (LWC)

#### Scenario: Custom Datatable for Account Management

#### Objective
Create a tab named **"LWC Accounts"** to display and manage **Account** records using a **custom LWC datatable**. Users should be able to edit **Account** details **inline**.

#### Requirements
1. **Tab Name**
   - "LWC Accounts"

2. **Fields Required on Account Object**
   - Country: Picklist field
   - Status: Picklist field with values:
     - Active
     - Inactive
     - Created
     - Closed
   - Account Activation Date: Date field
   - Comments: Long Text Area field

3. **Custom Datatable Features**
   - Display the following fields:
     - **Country**: Editable picklist field
     - **Status with Icon**: Display an SLDS icon for each status
     - **Account Activation Date**: Editable date field
     - **Comments**: Editable text area

4. **Inline Editing**
   - Users should be able to **edit Account details** directly within the datatable.

