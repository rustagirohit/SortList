USE [MCRT]
GO
/****** Object:  StoredProcedure [dbo].[AddMCRTAcessRequest]    Script Date: 9/17/2017 10:36:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [dbo].[AddMCRTAcessRequest]
@RacfId varchar(50),
@BusinessJustification nvarchar(512)=null,
@Error int = null OutPut,
@ErrorMsg varchar(300) = null Output
AS
SET XACT_ABORT ON;  
BEGIN TRY                                                                                                                    
SET NOCOUNT ON;                        
BEGIN TRAN 

SET @Error=0;
SET @ErrorMsg='';

If exists (select top 1 1 from tblMCRTAccessRequests 
Where LTRIM(RTRIM(RacfId))=LTRIM(RTRIM(@RacfId)) and [Status]=0)
BEGIN
Update tblMCRTAccessRequests
SET BusinessJustification =LTRIM(RTRIM(@BusinessJustification)),
ModifiedDate=GETUTCDATE(),ModifiedBy=@RacfId
WHERE LTRIM(RTRIM(RacfId))=LTRIM(RTRIM(@RacfId)) and [Status]=0;

Select @ErrorMsg='Request Added Successfully.';

END
ELSE
BEGIN
Insert into tblMCRTAccessRequests(RacfId,BusinessJustification,
CreatedBy,[Status])
Select LTRIM(RTRIM(@RacfId)),LTRIM(RTRIM(@BusinessJustification)),@RacfId,0;

If(SCOPE_IDENTITY() >0)
Begin
Select @ErrorMsg='Request Added Successfully.';
end
ELSE
begin
SELECT @ErrorMsg='Something Went Wrong...Plz try again.';
end

END

COMMIT TRAN;                                             
SET NOCOUNT OFF;                                       
END TRY                                                                                                          
BEGIN CATCH 
IF (XACT_STATE()) = -1  
BEGIN                                                           
ROLLBACK TRAN;  
PRINT 'error'                                    
SET @ErrorMsg= ERROR_MESSAGE();     
SET @Error=1;
Print @ErrorMsg;
INSERT INTO tbldberrorlog VALUES (ERROR_NUMBER(), ERROR_MESSAGE(), getutcdate(),
 ERROR_PROCEDURE(),'@racfId - ' + cast(@RacfId as varchar))                                                                                                          
END;                                                                  
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[GetMCRTAcessRequests]    Script Date: 9/17/2017 10:36:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [dbo].[GetMCRTAcessRequests]
@Status int
AS
BEGIN

Select ContentId as RequestId,
RacfId,BusinessJustification,[Status],Convert(varchar(10),CreatedDate,126)
as CreatedDate from tblMCRTAccessRequests
Where [Status]=@Status Order By 1 Desc;

END

GO
/****** Object:  StoredProcedure [dbo].[UpdateMCRTAccessRequest]    Script Date: 9/17/2017 10:36:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [dbo].[UpdateMCRTAccessRequest]
@RequestId int,
@MCPAdminRacfId varchar(50),
@Status int,
@Remark nvarchar(512)=null,
@Error int = null OutPut,
@ErrorMsg varchar(300) = null Output
AS
SET XACT_ABORT ON;  
BEGIN TRY                                                                                                                    
SET NOCOUNT ON;                        
BEGIN TRAN 

SET @Error=0;
SET @ErrorMsg='';

If EXISTS (SELECT top 1 1 from 
tblMCRTAccessRequests where contentid=@RequestId)
BEGIN
Update tblMCRTAccessRequests
Set [Status]=@Status,ModifiedBy=@MCPAdminRacfId,
ModifiedDate=GETUTCDATE(),Remark=LTRIM(RTRIM(@Remark))
Where ContentId=@RequestId and [Status] in (0,3);

If(@Status=1)
BEGIN
Print 'Add User';
END

SET @ErrorMsg='';

END


COMMIT TRAN;                                             
SET NOCOUNT OFF;                                       
END TRY                                                                                                          
BEGIN CATCH 
IF (XACT_STATE()) = -1  
BEGIN                                                           
ROLLBACK TRAN;  
PRINT 'error'                                    
SET @ErrorMsg= ERROR_MESSAGE();     
SET @Error=1;
Print @ErrorMsg;
INSERT INTO tbldberrorlog VALUES (ERROR_NUMBER(), ERROR_MESSAGE(), getutcdate(),
 ERROR_PROCEDURE(),'@RequestId - ' + cast(@RequestId as varchar))                                                                                                          
END;                                                                  
END CATCH

GO
