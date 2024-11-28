# Database Creation

---

### Database ERD

### ERD

![ERD.svg](https://prod-files-secure.s3.us-west-2.amazonaws.com/4713c335-c72c-442e-85d9-cc39a51f0ea7/2cde71ed-8c88-407a-840b-d0a36cc62f23/ERD.svg)

### Database Schema

![Screenshot 2024-10-21 230421.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/4713c335-c72c-442e-85d9-cc39a51f0ea7/4182ffe3-685a-4107-8782-4ad3ce3f2457/Screenshot_2024-10-21_230421.png)

### SQL Script

- StreamingDBScript
    
    ```sql
    -- Create the database
    CREATE DATABASE MovieStreamingDB;
    GO
    
    USE MovieStreamingDB;
    GO
    
    -- Create Customer table (moved up in the script to avoid foreign key issues)
    CREATE TABLE Customer (
        Customer_ID VARCHAR(50) PRIMARY KEY,
        Name VARCHAR(100) NOT NULL,
        Date_Of_Birth DATE,
        Gender VARCHAR(20),
        Email VARCHAR(100),
        Phone VARCHAR(20)
    );
    GO
    -- Create Profile table (modified to include Customer_ID)
    CREATE TABLE Profile (
        Profile_ID VARCHAR(50) PRIMARY KEY,
        Customer_ID VARCHAR(50),
        User_Name VARCHAR(100) NOT NULL,
        Date_Of_Birth DATE,
        Gender VARCHAR(20),
        Profile_Creation_Date DATE,
        FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
    );
    GO
    -- Create Actor table
    CREATE TABLE Actor (
        Actor_ID VARCHAR(50) PRIMARY KEY,
        Actor_Name VARCHAR(100) NOT NULL
    );
    GO
    -- Create Movie table
    CREATE TABLE Movie (
        Movie_ID VARCHAR(50) PRIMARY KEY,
        Movie_Name VARCHAR(255) NOT NULL,
        Duration INT,
        Movie_Language VARCHAR(50),
        Release_Year INT
    );
    GO
    -- Create Movie_Actor table (junction table for many-to-many relationship)
    CREATE TABLE Movie_Actor (
        Movie_ID VARCHAR(50),
        Actor_ID VARCHAR(50),
        PRIMARY KEY (Movie_ID, Actor_ID),
        FOREIGN KEY (Movie_ID) REFERENCES Movie(Movie_ID),
        FOREIGN KEY (Actor_ID) REFERENCES Actor(Actor_ID)
    );
    GO
    -- Create Genre table
    CREATE TABLE Genre (
        Genre_ID VARCHAR(50) PRIMARY KEY,
        Genre_Name VARCHAR(50) NOT NULL
    );
    GO
    -- Create Movie_Genre table (junction table for many-to-many relationship)
    CREATE TABLE Movie_Genre (
        Movie_ID VARCHAR(50),
        Genre_ID VARCHAR(50),
        PRIMARY KEY (Movie_ID, Genre_ID),
        FOREIGN KEY (Movie_ID) REFERENCES Movie(Movie_ID),
        FOREIGN KEY (Genre_ID) REFERENCES Genre(Genre_ID)
    );
    GO
    -- Create User_Rating table
    CREATE TABLE User_Rating (
        Rating_ID VARCHAR(50) PRIMARY KEY,
        Profile_ID VARCHAR(50),
        Movie_ID VARCHAR(50),
        FOREIGN KEY (Profile_ID) REFERENCES Profile(Profile_ID),
        FOREIGN KEY (Movie_ID) REFERENCES Movie(Movie_ID)
    );
    GO
    -- Create Activity table
    CREATE TABLE Activity (
        Activity_ID VARCHAR(50) PRIMARY KEY,
        Profile_ID VARCHAR(50),
        Activity_Type_Name VARCHAR(50),
        Duration INT,
        FOREIGN KEY (Profile_ID) REFERENCES Profile(Profile_ID)
    );
    GO
    -- Create Watching_History table
    CREATE TABLE Watching_History (
        History_ID VARCHAR(50) PRIMARY KEY,
        Profile_ID VARCHAR(50),
        Movie_ID VARCHAR(50),
        FOREIGN KEY (Profile_ID) REFERENCES Profile(Profile_ID),
        FOREIGN KEY (Movie_ID) REFERENCES Movie(Movie_ID)
    );
    GO
    -- Create Address table
    CREATE TABLE Address (
        Address_ID VARCHAR(50) PRIMARY KEY,
        Customer_ID VARCHAR(50),
        Address_Line VARCHAR(255),
        City VARCHAR(100),
        State VARCHAR(100),
        Country VARCHAR(100),
        Postal_Code VARCHAR(20),
        FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
    );
    GO
    -- Create User_Plan table
    CREATE TABLE User_Plan (
        Plan_ID VARCHAR(50) PRIMARY KEY,
        Plan_Name VARCHAR(50) NOT NULL
    );
    GO
    -- Create Subscription table
    CREATE TABLE Subscription (
        Subscription_ID VARCHAR(50) PRIMARY KEY,
        Status VARCHAR(20),
        Start_Date DATE,
        End_Date DATE,
        Customer_ID VARCHAR(50),
        Plan_ID VARCHAR(50),
        FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
        FOREIGN KEY (Plan_ID) REFERENCES User_Plan(Plan_ID)
    );
    GO
    -- Create Payment table
    CREATE TABLE Payment (
        Payment_ID VARCHAR(50) PRIMARY KEY,
        Customer_ID VARCHAR(50),
        Subscription_ID VARCHAR(50),
        Payment_Method VARCHAR(50),
        Payment_Date DATE,
        Amount DECIMAL(10, 2),
        FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
        FOREIGN KEY (Subscription_ID) REFERENCES Subscription(Subscription_ID)
    );
    GO
    ```
    

# Data Warehouse Diagram

### Data Warehouse Schema:

![datawarehouse4.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/4713c335-c72c-442e-85d9-cc39a51f0ea7/15e20b66-7865-47c5-9da3-07d4dfb8ace9/datawarehouse4.png)

### Data Warehouse Script:

```sql
-- Create the database
CREATE DATABASE StreamingDW2
GO
USE StreamingDW2;
GO

-- Create the Customer dimension table
CREATE TABLE DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(50) NOT NULL,
    Name NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(50),
    AddressLine NVARCHAR(255),
    City NVARCHAR(50),
    State NVARCHAR(50),
    Country NVARCHAR(50),
    PostalCode NVARCHAR(50),
    SubscriptionStatus NVARCHAR(20),
    PaymentMethod NVARCHAR(50)
);
GO

-- Create the Profile dimension table
CREATE TABLE DimProfile (
    ProfileKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerKey INT NOT NULL,
    ProfileID NVARCHAR(50) NOT NULL,
    UserName NVARCHAR(100),
    Gender CHAR(1),
    BirthDate DATE,
    ProfileCreationDate DATE,
    CONSTRAINT FK_DimProfile_Customer FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey)
);
GO

-- Create the Date dimension table
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    DayOfWeek TINYINT,
    DayName NVARCHAR(20),
    DayOfMonth TINYINT,
    DayOfYear SMALLINT,
    WeekOfYear TINYINT,
    MonthName NVARCHAR(20),
    MonthOfYear TINYINT,
    Quarter TINYINT,
    Year SMALLINT
);
GO

-- Create the Movie dimension table
CREATE TABLE DimMovie (
    MovieKey INT IDENTITY(1,1) PRIMARY KEY,
    MovieID NVARCHAR(50) NOT NULL,
    GenreID NVARCHAR(50) NOT NULL,
    ActorID NVARCHAR(50) NOT NULL,
    MovieName NVARCHAR(100),
    MovieRate DECIMAL(3,2),
    Duration INT,
    MovieLanguage NVARCHAR(50),
    ReleaseYear INT
);
GO

-- Create the Genre dimension table
CREATE TABLE DimGenre (
    GenreKey INT IDENTITY(1,1) PRIMARY KEY,
    MovieKey INT,
    GenreID NVARCHAR(50) NOT NULL,
    GenreName NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_DimGenre_Movie FOREIGN KEY (MovieKey) REFERENCES DimMovie(MovieKey)
);
GO

-- Create the Actor dimension table
CREATE TABLE DimActor (
    ActorKey INT IDENTITY(1,1) PRIMARY KEY,
    ActorID NVARCHAR(50) NOT NULL,
    MovieKey INT,
    ActorName NVARCHAR(100),
    CONSTRAINT FK_DimActor_Movie FOREIGN KEY (MovieKey) REFERENCES DimMovie(MovieKey)
);
GO

-- Create Plan dimension table
CREATE TABLE DimPlan (
    PlanKey INT IDENTITY(1,1) PRIMARY KEY,
    PlanID NVARCHAR(50) NOT NULL,
    PlanName NVARCHAR(50)
);
GO

-- Create the denormalized Fact table
CREATE TABLE FactStreamingDW2 (
    FactKey INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Foreign Keys for Dimensions
    DateKey INT NOT NULL,
    ProfileKey INT NOT NULL,
    CustomerKey INT,
    MovieKey INT,
    PlanKey INT,
    
    -- Attributes from FactStreaming (watching movies)
    WatchDuration INT,
    UserRating DECIMAL(3,2),
    
    -- Attributes from FactActivity
    ActivityType NVARCHAR(50),
    ActivityDuration INT,
    
    -- Attributes from FactSubscription
    StartDateKey INT, -- Subscription Start Date
    EndDateKey INT,   -- Subscription End Date
    SubscriptionDuration INT, -- in days
    PaymentAmount DECIMAL(10,2),
    
    -- Foreign Key Constraints
    CONSTRAINT FK_FactStreamingDW2_Date FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactStreamingDW2_Profile FOREIGN KEY (ProfileKey) REFERENCES DimProfile(ProfileKey),
    CONSTRAINT FK_FactStreamingDW2_Customer FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
    CONSTRAINT FK_FactStreamingDW2_Movie FOREIGN KEY (MovieKey) REFERENCES DimMovie(MovieKey),
    CONSTRAINT FK_FactStreamingDW2_Plan FOREIGN KEY (PlanKey) REFERENCES DimPlan(PlanKey),
    CONSTRAINT FK_FactStreamingDW2_StartDate FOREIGN KEY (StartDateKey) REFERENCES DimDate(DateKey),
	  CONSTRAINT FK_FactStreamingDW2_EndDate FOREIGN KEY (EndDateKey) REFERENCES DimDate(DateKey)
);
GO
```

# Data Warehouse Documentation for StreamingDB

## 1. Introduction

This document outlines the design and implementation of a data warehouse for the **StreamingDB** database, aimed at supporting analytical queries related to streaming data, customer interactions, and subscription management.

## 2. Objectives

The primary objectives of creating this data warehouse include:

- To consolidate and optimize data from various operational databases into a single source for analytical reporting.
- To support complex queries that facilitate business intelligence activities such as reporting, trend analysis, and forecasting.
- To provide a clear, simplified schema for end-users to easily navigate and extract insights.

## 3. Data Sources

The data warehouse was built using the following tables from the **StreamingDB02** relational database:

1. **Movie**: Contains movie-related information.
2. **Genre**: Contains genre names.
3. **Actor**: Contains actor names.
4. **Customer**: Stores customer details.
5. **Address**: Contains customer address information.
6. **User_Plan**: Stores subscription plan details.
7. **Subscription**: Contains subscription status and duration.
8. **Payment**: Holds payment details.
9. **Profile**: Contains profile information for customers.
10. **Watching_History**: Logs movies watched by profiles.
11. **User_Rating**: Stores ratings provided by users for movies.
12. **Activity**: Logs user activities related to the streaming service.

## 4. Design Approach

### 4.1 Schema Design

The data warehouse was designed using a **star schema** approach, which includes:

- A central **fact table** that captures key performance metrics.
- Associated **dimension tables** that provide contextual information for the metrics.

### 4.1.1 Fact Table

- **FactStreaming**: This fact table consolidates metrics from various sources related to user streaming activity.
    - **Key Attributes**: `StreamingKey`, `DateKey`, `CustomerKey`, `MovieKey`, `PlanKey`, `WatchDuration`, `SubscriptionDuration`, `PaymentAmount`, `UserRating`, `ActivityDuration`, `ActivityType`, `SubscriptionStatus`, `PaymentMethod`.

### 4.1.2 Dimension Tables

- **DimCustomer**: Combines data from `Customer`, `Address`, and `Profile` tables.
    - **Key Attributes**: `CustomerKey`, `CustomerID`, `FirstName`, `LastName`, `Email`, `Phone`, `Gender`, `BirthDate`, `AddressLine`, `City`, `State`, `Country`, `PostalCode`, `ProfileID`, `UserName`, `ProfileGender`, `ProfileBirthDate`, `ProfileCreationDate`.
- **DimDate**: Holds date-related information for analytics.
    - **Key Attributes**: `DateKey`, `FullDate`, `DayOfWeek`, `DayName`, `DayOfMonth`, `DayOfYear`, `WeekOfYear`, `MonthName`, `MonthOfYear`, `Quarter`, `Year`.
- **DimMovie**: Contains movie-related attributes, including associated actors and genres.
    - **Key Attributes**: `MovieKey`, `MovieID`, `MovieName`, `ContentRate`, `MovieRate`, `Duration`, `MovieLanguage`, `ReleaseYear`, `ActorList`, `GenreList`.
- **DimPlan**: Captures subscription plan information.
    - **Key Attributes**: `PlanKey`, `PlanID`, `PlanName`.

### 4.2 Denormalization

Denormalization was performed to reduce complexity and improve query performance. Related data from multiple tables were consolidated into the fact and dimension tables to optimize for read-heavy operations typical in analytical environments.

## 5. Implementation Steps

### 5.1 Database Creation

```sql
-- Create StreamingDB
CREATE DATABASE StreamingWH;
GO

USE StreamingWH;
GO

```

### 5.2 Table Creation

The following SQL commands were executed to create necessary tables:

- Fact Table
    
    ```sql
    CREATE TABLE FactStreaming (
        StreamingKey INT PRIMARY KEY,
        DateKey INT,
        CustomerKey INT,
        MovieKey INT,
        PlanKey INT,
        WatchDuration INT,
        SubscriptionDuration INT,
        PaymentAmount DECIMAL(10,2),
        UserRating INT,
        ActivityDuration INT,
        ActivityType NVARCHAR(100),
        SubscriptionStatus NVARCHAR(20),
        PaymentMethod NVARCHAR(50),
        FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
        FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
        FOREIGN KEY (MovieKey) REFERENCES DimMovie(MovieKey),
        FOREIGN KEY (PlanKey) REFERENCES DimPlan(PlanKey)
    );
    GO
    
    ```
    
- Dimension Tables
    
    ```sql
    CREATE TABLE DimCustomer (
        CustomerKey INT PRIMARY KEY,
        CustomerID INT,
        FirstName NVARCHAR(100),
        LastName NVARCHAR(100),
        Email NVARCHAR(255),
        Phone NVARCHAR(20),
        Gender NVARCHAR(20),
        BirthDate DATE,
        AddressLine NVARCHAR(255),
        City NVARCHAR(100),
        State NVARCHAR(100),
        Country NVARCHAR(100),
        PostalCode NVARCHAR(20),
        ProfileID INT,
        UserName NVARCHAR(100),
        ProfileGender NVARCHAR(20),
        ProfileBirthDate DATE,
        ProfileCreationDate DATE
    );
    GO
    
    CREATE TABLE DimDate (
        DateKey INT PRIMARY KEY,
        FullDate DATE,
        DayOfWeek INT,
        DayName NVARCHAR(20),
        DayOfMonth INT,
        DayOfYear INT,
        WeekOfYear INT,
        MonthName NVARCHAR(20),
        MonthOfYear INT,
        Quarter INT,
        Year INT
    );
    GO
    
    CREATE TABLE DimMovie (
        MovieKey INT PRIMARY KEY,
        MovieID INT,
        MovieName NVARCHAR(255),
        ContentRate NVARCHAR(10),
        MovieRate DECIMAL(3,1),
        Duration INT,
        MovieLanguage NVARCHAR(50),
        ReleaseYear INT,
        ActorList NVARCHAR(MAX),
        GenreList NVARCHAR(MAX)
    );
    GO
    
    CREATE TABLE DimPlan (
        PlanKey INT PRIMARY KEY,
        PlanID INT,
        PlanName NVARCHAR(50)
    );
    GO
    
    ```
    

## 6. Data Transformation and Loading (ETL)

The ETL process involved extracting data from the operational database, transforming it to fit the star schema model, and loading it into the newly created tables. This process included:

- Aggregating and joining data from the operational database.
- Flattening relationships (e.g., creating `ActorList` and `GenreList`).
- Ensuring data integrity and consistency during the load.

## 7. Data Warehouse Matrix Bus

The following matrix illustrates the relationships between the fact and dimension tables:

| Fact Tables | DimCustomer | DimDate | DimMovie | DimPlan |
| --- | --- | --- | --- | --- |
| **FactStreaming** | Yes | Yes | Yes | Yes |

## 8. Conclusion

The creation of the data warehouse for the **StreamingDB02** database provides a robust framework for analyzing streaming data. The star schema design optimizes for performance and ease of use, enabling efficient reporting and analytical capabilities. Future enhancements may include additional dimensions or fact tables based on evolving business requirements.

---

---

## Data Warehouse Matrix Bus Before Denormalization

## Data Warehouse Matrix Bus (Before Denormalization)

| Business Process (Facts) | Date | Customer | Subscription Plan | Profile | Movie | Genre | Actor | Payment Method | Activity Type | Address |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Watch History | X | X | X | X | X | X | X |  |  |  |
| User Activity | X | X |  | X |  |  |  |  | X |  |
| Subscriptions | X | X | X |  |  |  |  |  |  |  |
| Payments | X | X | X |  |  |  |  | X |  |  |

### Explanation of the Matrix (Before Denormalization)

1. **Fact Tables**:
    - **FactWatchingHistory**:
        - This fact table contains information about user viewing activities. It links to multiple dimension tables to capture details about the date, customer, subscription plan, movie, genre, and actor.
    - **FactSubscription**:
        - This fact table is centered around subscriptions, linking to the customer and subscription plan dimensions to capture relevant details about user subscriptions.
    - **FactActivity**:
        - This captures various user activities (e.g., logins, interactions) linked to the customer and date dimensions, providing insights into user engagement over time.
    - **FactPayment**:
        - This fact table focuses on payment transactions, referencing customers and dates to track payment history, types, and amounts.
2. **Dimension Tables**:
    - **DimDate**:
        - Contains attributes related to dates, such as day, month, and year, allowing for time-based analysis of facts.
    - **DimCustomer**:
        - Stores detailed customer information, including demographics and contact details, enabling segmentation and targeting analysis.
    - **DimMovie**:
        - Holds movie details such as title, release year, and rating. It connects to the `DimGenre` and `DimActor` tables due to many-to-many relationships (a movie can belong to multiple genres and have multiple actors).
    - **DimGenre**:
        - Contains unique genres associated with movies, allowing for genre-specific analysis.
    - **DimActor**:
        - Includes unique actors linked to movies, enabling actor-specific insights.
    - **DimPlan**:
        - Contains details about user subscription plans, such as name and features, facilitating subscription analysis.
    - **DimProfile**:
        - Contains information about user profiles, such as usernames and preferences, linking them to customer data.

### Summary of Relationships

- The matrix illustrates the relationships between the fact tables and their corresponding dimensions, highlighting how many-to-many relationships (like those between movies and genres, and movies and actors) are reflected in the fact tables.
- This structure supports complex queries that can analyze user behavior, payment trends, and content consumption across various dimensions.

### Next Steps

- After understanding the normalized structure, the next step would typically involve denormalizing these tables to create a star schema. This would simplify query complexity and improve performance for reporting and analytics.

---

## Data Warehouse Matrix Bus After Denormalization

After denormalization, the matrix reflects a simplified star schema where relationships are consolidated:

| Fact Tables | DimCustomer | DimDate | DimMovie | DimPlan |
| --- | --- | --- | --- | --- |
| **FactStreaming** | Yes | Yes | Yes | Yes |

### Explanation of the Matrix (After Denormalization)

1. **Fact Table**:
    - **FactStreaming**: The central fact table, combining streaming-related metrics, directly linking to all relevant dimension tables.
2. **Dimension Tables**:
    - **DimCustomer**: Merged customer data now directly related to the fact table.
    - **DimDate**: Provides contextual date-related information for streaming activities.
    - **DimMovie**: Contains movie data with aggregated information (actor and genre lists) combined into a single dimension, removing the need for separate tables for genres and actors.
    - **DimPlan**: Directly linked to the fact table, representing subscription plan details.

### Summary of Changes

- **Before Denormalization**: The structure had multiple fact tables and separate dimension tables for genres and actors due to many-to-many relationships, creating complexity in the schema.
- **After Denormalization**: A simplified star schema with a single fact table and consolidated dimension tables, improving query performance and simplifying the data structure for easier analytics.

### **Streaming Service Data Warehouse Bus Matrix**

| **Business Process** | **Fact Table** | **DimCustomer** | **DimProfile** | **DimDate** | **DimMovie** | **DimGenre** | **DimActor** | **DimPlan** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Watching Movies** | `FactStreamingDW2` | Yes | Yes | Yes | Yes | Yes | Yes |  |
| **User Activities (Browsing)** | `FactStreamingDW2` | Yes | Yes | Yes |  |  |  |  |
| **Subscription Management** | `FactStreamingDW2` | Yes | Yes | Yes |  |  |  | Yes |
| **Payments** | `FactStreamingDW2` | Yes |  | Yes |  |  |  | Yes |
| **Customer Demographics Analysis** | `FactStreamingDW2` (aggregated) | Yes | Yes | Yes |  |  |  |  |
