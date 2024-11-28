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
