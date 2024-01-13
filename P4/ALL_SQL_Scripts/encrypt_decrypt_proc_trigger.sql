-- Create a stored procedure to decrypt payment information
CREATE PROCEDURE DecryptPaymentInfo
    @CustomerID INT
AS
BEGIN
    OPEN SYMMETRIC KEY MySymmetricKey DECRYPTION BY CERTIFICATE MyCertificate;

    SELECT 
        CustomerID,
        CONVERT(VARCHAR(MAX), DECRYPTBYKEY(EncryptedPaymentInfo)) AS DecryptedPaymentInfo
    FROM Customer
    WHERE CustomerID = @CustomerID;

    CLOSE SYMMETRIC KEY MySymmetricKey;
END;

