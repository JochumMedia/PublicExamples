DECLARE addresses CURSOR LOCAL FORWARD_ONLY FAST_FORWARD
FOR
	SELECT iadintnr
	FROM T_IVI01ADX
	WHERE iadintnr NOT IN (SELECT ktiadintnr FROM T_DPKONTO)

OPEN addresses

DECLARE @adintnr INT
DECLARE @next_key_dpkonto INT
DECLARE @next_key_dpkonto_result INT

DECLARE @next_key_dpbenutzer INT
DECLARE @next_key_dpbenutzer_result INT

DECLARE @new_password VARCHAR(36)
DECLARE @new_password_md5 VARCHAR(32)
DECLARE @new_pp_timestamp VARCHAR(22) = (SELECT FORMAT((SELECT CAST(CURRENT_TIMESTAMP AS datetime2)), N'yyyy-MM-dd\/HH:mm:00.00'))

FETCH NEXT FROM addresses INTO @adintnr

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC PORTAL.PPGetKeyDPKONTO @@Station = 200, @@count = 1, @@NEXTKEY = @next_key_dpkonto OUTPUT, @@ResultCode = @next_key_dpkonto_result OUTPUT
	EXEC GetNewPassword @newpassword = @new_password OUTPUT, @newpasswordmd5 = @new_password_md5 OUTPUT

	INSERT INTO T_DPKONTO(ktid, ktiadintnr, ktaktiv, ktanzliz, kttyp, ktpwinit, ctimest, timest, csachb, owner, priv, mutcode, ktuidpruef)
	VALUES (@next_key_dpkonto, @adintnr, 1, 25, 'B2B', @new_password, @new_pp_timestamp, @new_pp_timestamp, 'JMX', 'JMX', 100, 'U', 1);

	DECLARE contact CURSOR LOCAL FORWARD_ONLY FAST_FORWARD
	FOR
		SELECT iktschlf, iktemail
		FROM T_IVI01KTX
		WHERE iktschlf NOT IN (SELECT beniktschlf FROM T_DPBENUTZER) AND iktintnr = @adintnr

		OPEN contact
			DECLARE @ktschlf INT
			DECLARE @ktemail VARCHAR(100)

			FETCH NEXT FROM contact INTO @ktschlf, @ktemail

			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC PORTAL.PPGetKeyDPBENUTZER @@Station = 200, @@count = 1, @@NEXTKEY = @next_key_dpbenutzer OUTPUT, @@ResultCode = @next_key_dpbenutzer_result OUTPUT
				EXEC GetNewPassword @newpassword = @new_password OUTPUT, @newpasswordmd5 = @new_password_md5 OUTPUT

				INSERT INTO T_DPBENUTZER(benid, beniktschlf, benaktiv, benpasswort, ctimest, timest, csachb, owner, priv, mutcode, bengesperrt, benktid, benwkb, benname, benemail, benfrei, benmodstat, benauarch, benbenvw)
				VALUES (@next_key_dpbenutzer, @ktschlf, 1, @new_password_md5, @new_pp_timestamp, @new_pp_timestamp, 'JMX', 'JMX', 100, 'U', 0, @next_key_dpkonto, 1, @ktemail, @ktemail, 1, 'K', 1, 2);

				UPDATE T_IVI01KTX
				SET iktcomm2 = @new_password
				WHERE iktschlf = @ktschlf

				FETCH NEXT FROM contact INTO @ktschlf, @ktemail
			END
		CLOSE contact
		DEALLOCATE contact

	FETCH NEXT FROM addresses INTO @adintnr
END