/*
Purpose: Create the EcommerceAnalytics database if it does not already exist.
Run this script first, using a login with database-creation permissions.
*/
IF DB_ID(N'EcommerceAnalytics') IS NULL
BEGIN
    CREATE DATABASE EcommerceAnalytics;
END;
GO
