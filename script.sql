USE [master]
GO
/****** Object:  Database [Supermarket]    Script Date: 23.06.2024 23:18:57 ******/
CREATE DATABASE [Supermarket]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Supermarket_Data', FILENAME = N'/var/opt/mssql/data\Supermarket.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Supermarket_Log', FILENAME = N'/var/opt/mssql/data\Supermarket.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [Supermarket] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Supermarket].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Supermarket] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Supermarket] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Supermarket] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Supermarket] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Supermarket] SET ARITHABORT OFF 
GO
ALTER DATABASE [Supermarket] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Supermarket] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Supermarket] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Supermarket] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Supermarket] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Supermarket] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Supermarket] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Supermarket] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Supermarket] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Supermarket] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Supermarket] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Supermarket] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Supermarket] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Supermarket] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Supermarket] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Supermarket] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Supermarket] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Supermarket] SET RECOVERY FULL 
GO
ALTER DATABASE [Supermarket] SET  MULTI_USER 
GO
ALTER DATABASE [Supermarket] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Supermarket] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Supermarket] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Supermarket] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Supermarket] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Supermarket] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'Supermarket', N'ON'
GO
ALTER DATABASE [Supermarket] SET QUERY_STORE = ON
GO
ALTER DATABASE [Supermarket] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [Supermarket]
GO
/****** Object:  UserDefinedFunction [dbo].[GetCustomer]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetCustomer]
(
 @country AS nvarchar(40)
)
RETURNS
@result TABLE
(
	FirstName nvarchar(40),
	LastName nvarchar(40),
	TotalAmount decimal(12,2)
)
AS
BEGIN
	INSERT INTO @result
		SELECT TOP(1) cu.LastName, cu.FirstName , sum(o.TotalAmount) AS SumTotalAmount
			FROM Orders o
			INNER JOIN  Customer cu ON o.CustomerId=cu.id
			INNER JOIN  City ci ON ci.id=cu.CityId
			INNER JOIN  Country co ON co.id=ci.CountryId
			WHERE co.Name =@country
			GROUP BY CustomerId,cu.FirstName, cu.Lastname
			ORDER BY SumTotalAmount DESC
	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetOrderTotal]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetOrderTotal]
(
	@orderId AS integer
)
RETURNS decimal(12,2)
AS
BEGIN
	DECLARE @totalAmount AS decimal(12,2);
	SELECT @totalAmount = SUM(UnitPrice*Quantity) FROM OrderItem
	WHERE OrderId=@orderId;
RETURN @totalAmount; 
END
GO
/****** Object:  Table [dbo].[OrderItem]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderItem](
	[id] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[UnitPrice] [numeric](12, 2) NOT NULL,
	[Quantity] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_OrderItem] UNIQUE NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[id] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[OrderNumber] [varchar](10) NULL,
	[CustomerID] [int] NOT NULL,
	[TotalAmount] [numeric](12, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_Orders] UNIQUE NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Product]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product](
	[id] [int] NOT NULL,
	[ProductName] [varchar](50) NOT NULL,
	[SupplierID] [int] NOT NULL,
	[UnitPrice] [numeric](12, 2) NULL,
	[IsDiscontinued] [bit] NOT NULL,
	[PackageId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Supplier]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Supplier](
	[id] [int] NOT NULL,
	[CompanyName] [varchar](40) NOT NULL,
	[ContactName] [varchar](50) NULL,
	[ContactTitle] [varchar](40) NULL,
	[Phone] [varchar](30) NULL,
	[Fax] [varchar](30) NULL,
	[CityId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Producs_Orders]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Producs_Orders]
AS
SELECT p.ProductName as 'Название товара',  oi.Quantity as 'Количество товара', oi.UnitPrice 'Стоимость в заказе',  s.CompanyName as 'Название компании поставщика'
FROM  Product  p
LEFT JOIN Supplier s ON s.id = p.SupplierID  
RIGHT JOIN  OrderItem  oi ON oi.ProductID = p.Id  
INNER JOIN  Orders  o ON o.ID = oi.OrderID
GO
/****** Object:  Table [dbo].[City]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[City](
	[ID] [int] NOT NULL,
	[Name] [nchar](50) NULL,
	[CountryId] [int] NULL,
 CONSTRAINT [PK_City] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Country]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Country](
	[ID] [int] NOT NULL,
	[Name] [nchar](50) NOT NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Product_Account]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Product_Account]
as
SELECT s.CompanyName as 'Название компании' , co.Name as 'Название страны', ci.Name as 'Название города', count(p.id ) as "Количество товаров"
FROM Country co
INNER JOIN   City ci ON ci.CountryId = co. Id 
INNER JOIN Supplier s ON s.CityId = ci.Id  
INNER JOIN  Product p ON p.SupplierID = s.Id 
GROUP BY  s.CompanyName , co.Name , ci.Name
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[Id] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Secondname] [nvarchar](50) NOT NULL,
	[Phone] [nvarchar](20) NULL,
	[CityId] [int] NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[get_customer_orders]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[get_customer_orders]()
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT o.CustomerId, c.LastName, c.FirstName, o.id AS OrderId, o.TotalAmount
    FROM Orders o
    JOIN Customer c ON o.CustomerId = c.id
    JOIN OrderItem oi ON o.id = oi.OrderId
)
GO
/****** Object:  UserDefinedFunction [dbo].[is_product_in_order]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[is_product_in_order]()
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT c.id AS CustomerId, c.LastName, c.FirstName, oi.ProductId, p.ProductName
    FROM Customer c
    JOIN Orders o ON c.id = o.CustomerId
    JOIN OrderItem oi ON o.id = oi.OrderId
    JOIN Product p ON oi.ProductId = p.id
)
GO
/****** Object:  Table [dbo].[ExportedCustomers]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExportedCustomers](
	[Id] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Secondname] [nvarchar](50) NOT NULL,
	[Phone] [nvarchar](20) NULL,
	[CityId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Package]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Package](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Package] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [OrderCustomer]    Script Date: 23.06.2024 23:18:57 ******/
CREATE NONCLUSTERED INDEX [OrderCustomer] ON [dbo].[Customer]
(
	[LastName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [DateOrder]    Script Date: 23.06.2024 23:18:57 ******/
CREATE NONCLUSTERED INDEX [DateOrder] ON [dbo].[Orders]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[City]  WITH CHECK ADD  CONSTRAINT [FK_City_Country] FOREIGN KEY([CountryId])
REFERENCES [dbo].[Country] ([ID])
GO
ALTER TABLE [dbo].[City] CHECK CONSTRAINT [FK_City_Country]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_City] FOREIGN KEY([CityId])
REFERENCES [dbo].[City] ([ID])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_City]
GO
ALTER TABLE [dbo].[OrderItem]  WITH CHECK ADD  CONSTRAINT [FK_OrderItem_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([id])
GO
ALTER TABLE [dbo].[OrderItem] CHECK CONSTRAINT [FK_OrderItem_Orders]
GO
ALTER TABLE [dbo].[OrderItem]  WITH CHECK ADD  CONSTRAINT [FK_OrderItem_Product] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Product] ([id])
GO
ALTER TABLE [dbo].[OrderItem] CHECK CONSTRAINT [FK_OrderItem_Product]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Customer]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_Package] FOREIGN KEY([PackageId])
REFERENCES [dbo].[Package] ([Id])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Package]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_Supplier1] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Supplier] ([id])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Supplier1]
GO
ALTER TABLE [dbo].[Supplier]  WITH CHECK ADD  CONSTRAINT [FK_Supplier_City] FOREIGN KEY([CityId])
REFERENCES [dbo].[City] ([ID])
GO
ALTER TABLE [dbo].[Supplier] CHECK CONSTRAINT [FK_Supplier_City]
GO
/****** Object:  StoredProcedure [dbo].[create_schedule]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[create_schedule]
AS
BEGIN
    DECLARE @order_id INT;
    DECLARE @order_date DATETIME;
    
    DECLARE OrderCursor CURSOR FOR
    SELECT id, OrderDate
    FROM Orders;
    
    OPEN OrderCursor;
    FETCH NEXT FROM OrderCursor INTO @order_id, @order_date;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRANSACTION;
        DELETE FROM Schedule
        WHERE completed = 0 AND EXISTS (
            SELECT 1
            FROM OrderItem oi
            INNER JOIN Schedule s ON s.order_item_id = oi.id
            WHERE oi.OrderId = @order_id
        );
        
        BEGIN TRY
            EXEC insert_order @order_id, @order_date;
        END TRY
        BEGIN CATCH
            PRINT('Error in procedure');
            ROLLBACK;
        END CATCH;
        
        COMMIT;
        FETCH NEXT FROM OrderCursor INTO @order_id, @order_date;
    END
    
    CLOSE OrderCursor;
    DEALLOCATE OrderCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteOldUncompletedOrders]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteOldUncompletedOrders]
    @days INT
AS
BEGIN
    DELETE FROM Orders
    WHERE DATEDIFF(DAY, OrderDate, GETDATE()) > @days AND id NOT IN (
        SELECT OrderId FROM OrderItem
    );
END
GO
/****** Object:  StoredProcedure [dbo].[GetCustomerInfoByName]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetCustomerInfoByName]
 @firstName AS nvarchar(40),
 @lastName  AS nvarchar(40)
AS
BEGIN
  SELECT * FROM Customer WHERE FirstName= @firstName AND LastName =@lastName;
END
GO
/****** Object:  StoredProcedure [dbo].[GetCustomerInfoByNameOrder]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetCustomerInfoByNameOrder]
 @firstName AS nvarchar(40),
 @lastName AS nvarchar(40)
AS
BEGIN
  DECLARE @customerId as integer	
  SELECT @customerId=id FROM Customer WHERE FirstName = @firstName AND LastName =@lastName;
	if (@customerId is not null) 
	BEGIN
		SELECT * FROM Customer WHERE Id = @customerId;
 		SELECT * FROM Orders WHERE CustomerId = @customerId;
	END;
END
exec GetCustomerInfoByNameOrder 'Иванов','Евгений'
GO
/****** Object:  StoredProcedure [dbo].[GetCustomersWithHighOrders]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetCustomersWithHighOrders]
    @minTotalAmount DECIMAL
AS
BEGIN
    SELECT c.id, c.LastName, c.FirstName, SUM(o.TotalAmount) AS TotalAmount
    FROM Customer c
    JOIN Orders o ON c.id = o.CustomerId
    GROUP BY c.id, c.LastName, c.FirstName
    HAVING SUM(o.TotalAmount) > @minTotalAmount;
END
GO
/****** Object:  StoredProcedure [dbo].[insert_order]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[insert_order]
    @order_id INT,
    @order_date DATETIME
AS
BEGIN
    INSERT INTO Schedule (order_item_id, start_date, completed)
    SELECT id, @order_date, 0
    FROM OrderItem
    WHERE OrderId = @order_id;
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateProductInfo]    Script Date: 23.06.2024 23:18:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateProductInfo]
    @productId INT,
    @newProductName NVARCHAR(100),
    @newUnitPrice DECIMAL
AS
BEGIN
    UPDATE Product
    SET ProductName = @newProductName, UnitPrice = @newUnitPrice
    WHERE id = @productId;
END
GO
USE [master]
GO
ALTER DATABASE [Supermarket] SET  READ_WRITE 
GO
