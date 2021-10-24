CREATE PROCEDURE GetNewPassword (
	@newpassword VARCHAR(36) OUTPUT,
	@newpasswordmd5 VARCHAR(32) OUTPUT
)
AS
BEGIN
DECLARE @counter INT = 0;
DECLARE @randPosition INT = 0;
DECLARE @symbolNr INT = 0;
DECLARE @randLenght INT = FLOOR(RAND()*(19-5)+5);
DECLARE @symbols VARCHAR(43) = '!§$%&()?+*-_|<>[]{}abcdefghijklmnopqrstuvwxyz';
DECLARE @password VARCHAR(36) = NEWID();
DECLARE @passwordLenght VARCHAR(36) = FLOOR(RAND()*(36-16)+16);

WHILE @counter < @randLenght
BEGIN
SET @symbolNr = FLOOR(RAND()*(44-1)+1);
   SET @randPosition = FLOOR(RAND()*(36-1)+1);
   SET @password = STUFF(@password, @randPosition , 1 , SUBSTRING(@symbols,@symbolNr,1));
   SET @counter += 1;
END;
SET @password = LEFT(@password,@passwordLenght);
DECLARE @pwMd5 VARCHAR(32) = CONVERT(VARCHAR(32), HASHBYTES('MD5', @password), 2);
SELECT @newpassword = @password, @newpasswordmd5 = @pwMd5;
END;
